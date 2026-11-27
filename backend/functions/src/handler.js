import { parseRequest, project } from './projection.js';

export function createTransitCacheHandler(resolve) {
  return async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('POST required');
      return;
    }
    let source;
    try {
      source = parseRequest(req.body);
    } catch {
      res.status(400).send('Unsupported transit query');
      return;
    }
    try {
      const snapshot = await resolve(source);
      const result = snapshot.downloadUrl
        ? {bytes: Buffer.alloc(0), contentType: 'application/zip'}
        : project(snapshot.bytes, source.kind, source.filter, `${source.url}:${snapshot.fetchedAt}`);
      if (result.bytes.length > 28 * 1024 * 1024) {
        throw new Error('Inline response exceeds limit');
      }
      if (snapshot.downloadUrl) {
        res.set('X-Transit-Download-Url', snapshot.downloadUrl);
      }
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
  };
}
