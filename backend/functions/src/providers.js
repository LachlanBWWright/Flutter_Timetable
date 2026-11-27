import {createHmac} from 'node:crypto';
import sources from './provider-sources.json' with {type: 'json'};

export function canonicalUrl(value) {
  const url = new URL(value);
  url.searchParams.sort();
  return url.href;
}
const catalog = new Map(sources.map(source => [canonicalUrl(source.url), source]));
const ptvPaths = [
  /^\/v3\/search\/[^/]+$/,
  /^\/v3\/stops\/\d+\/route_type\/[0-4]$/,
  /^\/v3\/departures\/route_type\/[0-4]\/stop\/\d+$/,
  /^\/v3\/disruptions(?:\/stop\/\d+)?$/,
];
const ptvParameters = new Set(['include_outlets', 'match_stop_by_suburb', 'match_route_by_suburb', 'stop_location', 'stop_accessibility', 'stop_disruptions', 'gtfs', 'date_utc', 'max_results', 'include_cancelled']);

export function providerSource(url) {
  const registered = catalog.get(canonicalUrl(url.href));
  if (registered) return {...registered, ttlMs: registered.kind === 'static' ? 6 * 3_600_000 : 30_000};
  if (url.origin !== 'https://timetableapi.ptv.vic.gov.au' || !ptvPaths.some(pattern => pattern.test(url.pathname))) return null;
  for (const key of url.searchParams.keys()) if (!ptvParameters.has(key)) throw new Error('Unsupported PTV parameter');
  const kind = url.pathname.startsWith('/v3/search/') ? 'ptvStops' : url.pathname.startsWith('/v3/stops/') ? 'ptvStop' : url.pathname.startsWith('/v3/departures/') ? 'ptvDepartures' : 'ptvDisruptions';
  return {provider: 'ptv', kind, ttlMs: ['ptvStops', 'ptvStop'].includes(kind) ? 3_600_000 : 30_000};
}

export function upstreamRequest(source, {tfnswApiKey = '', victoriaOpenDataApiKey = '', ptvDeveloperId = '', ptvApiKey = ''} = {}) {
  const url = new URL(source.url);
  const headers = {};
  if (source.provider === 'tfnsw') {
    if (!tfnswApiKey) throw new Error('TfNSW credentials unavailable');
    headers.Authorization = `apikey ${tfnswApiKey}`;
  } else if (source.provider === 'victoria' && url.host === 'api.opendata.transport.vic.gov.au') {
    if (!victoriaOpenDataApiKey) throw new Error('Victoria credentials unavailable');
    headers.KeyID = victoriaOpenDataApiKey;
  } else if (source.provider === 'ptv') {
    if (!ptvDeveloperId || !ptvApiKey) throw new Error('PTV credentials unavailable');
    url.searchParams.set('devid', ptvDeveloperId);
    url.searchParams.sort();
    // PTV uses form-encoded query components, as does the Flutter signer.
    const payload = `${url.pathname}?${url.searchParams.toString()}`;
    url.searchParams.set('signature', createHmac('sha1', ptvApiKey).update(payload).digest('hex').toUpperCase());
  }
  return {url: url.href, headers};
}

export async function downloadSource(source, credentials, fetcher = fetch) {
  let {url, headers} = upstreamRequest(source, credentials);
  const signal = AbortSignal.timeout(12_000);
  for (let redirects = 0; redirects <= 3; redirects++) {
    const response = await fetcher(url, {headers, signal, redirect: 'manual'});
    if ([301, 302, 303, 307, 308].includes(response.status)) {
      const next = new URL(response.headers.get('location'), url);
      await response.body?.cancel();
      // Static publisher URLs may redirect to downloads on the same origin.
      // Realtime/credential-bearing requests never follow redirects.
      if (source.kind !== 'static' || next.origin !== new URL(source.url).origin || next.username || next.password || redirects === 3) throw new Error('Unsupported redirect');
      url = next.href;
      headers = {};
      continue;
    }
    if (!response.ok) throw new Error(`Provider HTTP ${response.status}`);
    const chunks = [];
    let size = 0;
    const limit = source.kind === 'static' ? 128 * 1024 * 1024 : 32 * 1024 * 1024;
    for await (const chunk of response.body) {
      size += chunk.length;
      if (size > limit) { await response.body.cancel().catch(() => {}); throw new Error('Source exceeds cache limit'); }
      chunks.push(chunk);
    }
    return Buffer.concat(chunks);
  }
  throw new Error('Redirect limit exceeded');
}
