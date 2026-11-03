import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage, getDownloadURL } from 'firebase-admin/storage';
import { defineJsonSecret } from 'firebase-functions/params';
import { onRequest } from 'firebase-functions/v2/https';
import { createResolver } from './cache.js';
import {downloadSource} from './providers.js';
import { parseRequest, project, validateSource } from './projection.js';

initializeApp();
const providerCredentials = defineJsonSecret('TRANSIT_PROVIDER_CREDENTIALS');
const db = getFirestore();
const ref = key => db.collection('transitSourceCache').doc(key);

const store = {
  async read(key) {
    const manifest = (await ref(key).get()).data();
    if (!manifest?.path || manifest.expiresAt <= Date.now()) return null;
    if (manifest.kind === 'static' && manifest.downloadUrl) return {downloadUrl: manifest.downloadUrl, fetchedAt: manifest.fetchedAt, expiresAt: manifest.expiresAt};
    const [bytes] = await getStorage().bucket().file(manifest.path).download();
    return {bytes, fetchedAt: manifest.fetchedAt, expiresAt: manifest.expiresAt};
  },
  claim(key, owner, now) {
    return db.runTransaction(async tx => {
      const doc = ref(key);
      const current = (await tx.get(doc)).data();
      if (current?.leaseUntil > now) return false;
      tx.set(doc, {owner, leaseUntil: now + 20_000}, {merge: true});
      return true;
    });
  },
  async publish(key, owner, snapshot) {
    const path = `transit-cache/${key}/${owner}`;
    const file = getStorage().bucket().file(path);
    await file.save(snapshot.bytes, {resumable: false, metadata: {contentType: snapshot.kind === 'static' ? 'application/zip' : 'application/octet-stream', metadata: snapshot.kind === 'static' ? {firebaseStorageDownloadTokens: owner} : {}}});
    const downloadUrl = snapshot.kind === 'static' ? await getDownloadURL(file) : null;
    const published = await db.runTransaction(async tx => {
      const doc = ref(key);
      const current = (await tx.get(doc)).data();
      if (current?.owner !== owner || current.leaseUntil <= Date.now()) return false;
      tx.set(doc, {path, kind: snapshot.kind, downloadUrl, fetchedAt: snapshot.fetchedAt, expiresAt: snapshot.expiresAt, owner: null, leaseUntil: 0});
      return true;
    });
    if (!published) await file.delete().catch(() => {});
    return published && downloadUrl ? {downloadUrl} : null;
  },
  release(key, owner) {
    return db.runTransaction(async tx => {
      const doc = ref(key);
      const current = (await tx.get(doc)).data();
      if (current?.owner === owner) tx.set(doc, {owner: null, leaseUntil: 0}, {merge: true});
    });
  },
};

const resolve = createResolver({store, fetchSource: async source => {
  const bytes = await downloadSource(source, providerCredentials.value());
  validateSource(bytes, source.kind);
  return {bytes};
}});

export const transitCache = onRequest({
  region: 'australia-southeast1', cors: true, timeoutSeconds: 30,
  memory: '1GiB', concurrency: 2, maxInstances: 5, secrets: [providerCredentials],
}, async (req, res) => {
  if (req.method !== 'POST') { res.status(405).send('POST required'); return; }
  let source;
  try { source = parseRequest(req.body); }
  catch { res.status(400).send('Unsupported transit query'); return; }
  try {
    const snapshot = await resolve(source);
    const result = snapshot.downloadUrl
      ? {bytes: Buffer.alloc(0), contentType: 'application/zip'}
      : project(snapshot.bytes, source.kind, source.filter, `${source.url}:${snapshot.fetchedAt}`);
    if (result.bytes.length > 28 * 1024 * 1024) throw new Error('Inline response exceeds limit');
    if (snapshot.downloadUrl) res.set('X-Transit-Download-Url', snapshot.downloadUrl);
    res.set({
      'Content-Type': result.contentType,
      'Cache-Control': 'no-store',
      'X-Transit-Version': '1',
      'X-Transit-Fetched-At': new Date(snapshot.fetchedAt).toISOString(),
      'X-Transit-Expires-At': new Date(snapshot.expiresAt).toISOString(),
      'Access-Control-Expose-Headers': 'X-Transit-Version, X-Transit-Fetched-At, X-Transit-Expires-At, X-Transit-Download-Url',
    }).status(200).send(result.bytes);
  } catch {
    // No provider body, credentials or journey parameters in logs/responses.
    res.status(503).send('Shared transit data unavailable');
  }
});
