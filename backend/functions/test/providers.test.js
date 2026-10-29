import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createHmac} from 'node:crypto';
import protobuf from 'protobufjs';
import sources from '../src/provider-sources.json' with {type: 'json'};
import {upstreamRequest, downloadSource} from '../src/providers.js';
import {parseRequest, project, Feed, validateSource} from '../src/projection.js';
import {createResolver} from '../src/cache.js';

const parse = url => parseRequest({version: 1, url, filter: {}});

test('all registered providers use isolated canonical cache sources', () => {
  for (const entry of sources) {
    const source = parse(entry.url);
    assert.equal(source.provider, entry.provider);
    assert.equal(source.kind, entry.kind);
    assert.equal(source.ttlMs, entry.kind === 'static' ? 21_600_000 : 30_000);
    assert.throws(() => parse(`${entry.url}${entry.url.includes('?') ? '&' : '?'}api_key=private`));
  }
});

test('Flutter and backend source catalogs stay in sync', () => {
  const dart = readFileSync(new URL('../../../lib/transit/cache/provider_sources.dart', import.meta.url), 'utf8');
  const entries = [...dart.matchAll(/'(https:\/\/[^']+)':\s*'(static|realtime)'/g)].map(([,url,kind]) => [url, kind]);
  assert.deepEqual(entries, sources.map(({url,kind}) => [url,kind]));
});

test('credentials are sent only to their provider', () => {
  const credentials = {tfnswApiKey: 'nsw-test', victoriaOpenDataApiKey: 'vic-test'};
  const nsw = upstreamRequest(parse('https://api.transport.nsw.gov.au/v1/gtfs/realtime/buses'), credentials);
  assert.deepEqual(nsw.headers, {Authorization: 'apikey nsw-test'});
  for (const entry of sources) {
    const request = upstreamRequest(parse(entry.url), credentials);
    assert.deepEqual(request.headers, new URL(entry.url).host === 'api.opendata.transport.vic.gov.au' ? {KeyID: 'vic-test'} : {});
  }
});

test('legacy PTV requests are signed using backend credentials', () => {
  const url = 'https://timetableapi.ptv.vic.gov.au/v3/departures/route_type/0/stop/100?max_results=20&gtfs=true';
  const source = parse(url);
  const result = new URL(upstreamRequest(source, {ptvDeveloperId: '1234', ptvApiKey: 'test-only-key'}).url);
  const expected = createHmac('sha1', 'test-only-key').update('/v3/departures/route_type/0/stop/100?devid=1234&gtfs=true&max_results=20').digest('hex').toUpperCase();
  assert.equal(result.searchParams.get('signature'), expected);
  assert.equal(result.searchParams.get('devid'), '1234');
  assert.throws(() => parse(`${url}&signature=device-secret`));
  assert.throws(() => parse('https://timetableapi.ptv.vic.gov.au/v3/admin'));
  assert.throws(() => upstreamRequest(source, {}));
});

test('static redirects stay on the trusted origin without provider headers', async () => {
  const source = parse(sources.find(s => s.provider === 'transperth').url);
  const calls = [];
  const bytes = Buffer.from('archive');
  const result = await downloadSource(source, {tfnswApiKey: 'never-forward'}, async (url, options) => {
    calls.push({url, headers: options.headers});
    if (calls.length === 1) return new Response('', {status: 302, headers: {location: '/downloads/feed.zip'}});
    return new Response(bytes);
  });
  assert.deepEqual(result, bytes);
  assert.equal(calls.length, 2);
  assert.deepEqual(calls.map(c => c.headers), [{}, {}]);
  await assert.rejects(downloadSource(source, {}, async () => new Response('', {status: 302, headers: {location: 'https://other.example/private'}})));
});

test('unknown protobuf extensions survive both full and scoped responses', () => {
  // An extension unknown to the bundled GTFS decoder, inside one raw entity.
  const entity = Feed.lookupType('FeedEntity');
  const a = Buffer.from(entity.encode(entity.create({id: 'a', vehicle: {vehicle: {id: 'bus-a'}, trip: {tripId: 'a'}, position: {latitude: 1, longitude: 2}}})).finish());
  const extension = Buffer.from(protobuf.Writer.create().uint32((1001 << 3) | 2).bytes(Buffer.from('provider-extension')).finish());
  const aWithExtension = Buffer.concat([a, extension]);
  const b = entity.encode(entity.create({id: 'b', vehicle: {trip: {tripId: 'b'}}})).finish();
  const header = Feed.lookupType('FeedHeader').encode({gtfsRealtimeVersion: '2.0'}).finish();
  const bytes = Buffer.from(protobuf.Writer.create().uint32(10).bytes(header).uint32(18).bytes(aWithExtension).uint32(18).bytes(b).finish());
  assert.deepEqual(project(bytes, 'realtime', {}).bytes, bytes);
  const scoped = project(bytes, 'realtime', {tripIds: ['a']}).bytes;
  assert.equal(Feed.decode(scoped).entity.length, 1);
  assert.equal(scoped.includes(extension), true);
});

test('PTV projections keep referenced route/destination data and cancellations', () => {
  const bytes = Buffer.from(JSON.stringify({departures: [{route_id: 1, run_id: 2, direction_id: 3, flags: ['cancelled'], scheduled_departure_utc: '2026-10-28T12:00:00Z', unused: 'omit'}], routes: {1: {route_name: 'Train'}, 99: {route_name: 'unused'}}, runs: {2: {destination_name: 'City'}}, directions: {3: {direction_name: 'City'}}, unused: 'omit'}));
  const body = JSON.parse(project(bytes, 'ptvDepartures', {}).bytes);
  assert.deepEqual(body.departures[0].flags, ['cancelled']);
  assert.deepEqual(Object.keys(body.routes), ['1']);
  assert.equal(body.directions['3'].direction_name, 'City');
  assert.equal(body.unused, undefined);
  assert.equal(body.departures[0].unused, undefined);
});

test('bad static responses and unsupported source URLs are rejected', () => {
  assert.throws(() => validateSource(Buffer.from('<html>error</html>'), 'static'));
  assert.throws(() => parse('https://gtfsrt.api.translink.com.au/admin'));
  assert.throws(() => parse('https://api.opendata.transport.vic.gov.au/private'));
  assert.throws(() => parse('https://gtfs.adelaidemetro.com.au/v1/realtime/vehicle_positions?url=http://localhost'));
});

test('published archive pointers survive shared resolution', async () => {
  let calls = 0;
  const source = parse(sources.find(s => s.kind === 'static').url);
  const resolve = createResolver({store: {read: async () => null, claim: async () => true, publish: async () => ({downloadUrl: 'https://firebasestorage.googleapis.com/v0/b/test/o/archive?alt=media&token=public'}), release: async () => {}}, fetchSource: async () => {calls++; return {bytes: Buffer.from('archive')};}});
  const snapshot = await resolve(source);
  assert.equal(calls, 1);
  assert.equal(snapshot.kind, 'static');
  assert.ok(snapshot.downloadUrl.startsWith('https://firebasestorage.googleapis.com/'));
});
