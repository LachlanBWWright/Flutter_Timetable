import { createHash, randomUUID } from 'node:crypto';

export const sourceKey = url => createHash('sha256').update(`v1:${url}`).digest('hex');

/// Store methods implement shared source leases; query filters are deliberately
/// absent from the key so two trip queries share the same upstream download.
export function createResolver({store, fetchSource, now = Date.now, sleep = ms => new Promise(r => setTimeout(r, ms))}) {
  const inflight = new Map();
  async function refresh(source) {
    const key = sourceKey(source.url);
    let cached;
    let available = true;
    try { cached = await store.read(key); } catch { available = false; }
    if (cached && cached.expiresAt > now()) return cached;
    const owner = randomUUID();
    if (available) {
      const acquired = await store.claim(key, owner, now());
      if (!acquired) {
        // A bounded wait allows the app to fall back to its normal provider path.
        for (let i = 0; i < 8; i++) {
          await sleep(200);
          const result = await store.read(key);
          if (result && result.expiresAt > now()) return result;
        }
        throw new Error('Refresh already in progress');
      }
      // Another instance may have published between our first read and claim.
      const newer = await store.read(key);
      if (newer && newer.expiresAt > now()) {
        await store.release(key, owner);
        return newer;
      }
    }
    try {
      const downloaded = await fetchSource(source);
      const snapshot = {...downloaded, kind: source.kind, fetchedAt: now(), expiresAt: now() + source.ttlMs};
      // A failed cache write must not discard a successful upstream response.
      if (available) {
        try {
          const published = await store.publish(key, owner, snapshot);
          if (published?.downloadUrl) return {...snapshot, downloadUrl: published.downloadUrl};
        } catch { /* return fetched data */ }
      }
      return snapshot;
    } finally {
      if (available) {
        try { await store.release(key, owner); } catch { /* lease expires */ }
      }
    }
  }
  return source => {
    const key = sourceKey(source.url);
    if (inflight.has(key)) return inflight.get(key);
    const task = refresh(source).finally(() => { if (inflight.get(key) === task) inflight.delete(key); });
    inflight.set(key, task);
    return task;
  };
}
