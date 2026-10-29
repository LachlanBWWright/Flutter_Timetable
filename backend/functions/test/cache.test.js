import test from 'node:test';
import assert from 'node:assert/strict';
import {createResolver} from '../src/cache.js';
import {Feed, parseRequest, project} from '../src/projection.js';

const source = {url: 'https://api.transport.nsw.gov.au/v1/gtfs/realtime/buses', kind: 'realtime', ttlMs: 30_000};
function memoryStore() {
  const data = new Map();
  const leases = new Map();
  return {
    async read(key) {return data.get(key);},
    async claim(key, owner) {if (leases.has(key)) return false; leases.set(key, owner); return true;},
    async publish(key, owner, value) {if (leases.get(key) === owner) data.set(key, value);},
    async release(key, owner) {if (leases.get(key) === owner) leases.delete(key);},
  };
}

test('loaded shared snapshot avoids upstream and retains original age', async () => {
  let now = 100_000, calls = 0;
  const resolve = createResolver({store: memoryStore(), now: () => now, fetchSource: async () => {calls++; return {bytes: Buffer.from('feed')};}});
  const first = await resolve(source);
  now += 20_000;
  assert.deepEqual(await resolve(source), first);
  assert.equal(calls, 1);
  now += 11_000;
  assert.equal((await resolve(source)).fetchedAt, now);
  assert.equal(calls, 2);
});

test('different query filters share upstream work within and across instances', async () => {
  let calls = 0;
  const store = memoryStore();
  const options = {store, fetchSource: async () => {calls++; await new Promise(r => setTimeout(r, 10)); return {bytes: Buffer.from('feed')};}};
  const a = createResolver(options), b = createResolver(options);
  const results = await Promise.all([a({...source, filter: {tripIds: ['a']}}), a({...source, filter: {tripIds: ['b']}}), b(source)]);
  assert.equal(calls, 1);
  assert.equal(results.length, 3);
});

test('Firebase read/write failure does not discard successful provider data', async () => {
  for (const operation of ['read', 'publish']) {
    const store = memoryStore();
    store[operation] = async () => {throw new Error('Firebase unavailable');};
    const resolve = createResolver({store, fetchSource: async () => ({bytes: Buffer.from('fresh')})});
    assert.equal((await resolve(source)).bytes.toString(), 'fresh');
  }
});

test('failed upstream is not cached as empty and releases ownership', async () => {
  let calls = 0;
  const resolve = createResolver({store: memoryStore(), fetchSource: async () => {
    if (++calls === 1) throw new Error('offline');
    return {bytes: Buffer.from('ok')};
  }});
  await assert.rejects(resolve(source));
  assert.equal((await resolve(source)).bytes.toString(), 'ok');
});

const encode = entity => Buffer.from(Feed.encode(Feed.create({header: {gtfsRealtimeVersion: '2.0', timestamp: 123}, entity})).finish());
const trip = (tripId, startDate) => ({tripId, routeId: 'route', startDate, startTime: '10:00:00'});
test('trip projection preserves service instances and all required stop updates', () => {
  const bytes = encode([
    {id: 'a', tripUpdate: {trip: trip('a', '20261027'), stopTimeUpdate: [{stopId: 's1', stopSequence: 1, arrival: {time: 123}}, {stopId: 's2', stopSequence: 2}]}},
    {id: 'a-next-day', tripUpdate: {trip: trip('a', '20261028')}},
    {id: 'b', tripUpdate: {trip: trip('b', '20261027')}},
  ]);
  const result = Feed.decode(project(bytes, 'realtime', {tripIds: ['a']}).bytes);
  assert.equal(result.entity.length, 2);
  assert.equal(result.entity[0].tripUpdate.stopTimeUpdate.length, 2);
  assert.equal(result.entity[0].tripUpdate.trip.startDate, '20261027');
  assert.equal(result.header.timestamp.toNumber(), 123);
});

test('route filtering supports unknown trip identities; empty result is valid', () => {
  const bytes = encode([{id: 'v', vehicle: {trip: trip('a', '20261027'), vehicle: {id: 'bus'}, position: {latitude: 1, longitude: 2}, timestamp: 123}}]);
  assert.equal(Feed.decode(project(bytes, 'realtime', {routeId: 'route'}).bytes).entity.length, 1);
  assert.equal(Feed.decode(project(bytes, 'realtime', {tripIds: ['missing']}).bytes).entity.length, 0);
});

test('stop projection strips unused fields but retains name disassembly', () => {
  const bytes = Buffer.from(JSON.stringify({locations: [{id: 's', name: 'Station', disassembledName: 'Platform', type: 'stop', hugeUnusedField: [1,2,3]}]}));
  const result = JSON.parse(project(bytes, 'stops', {}).bytes);
  assert.deepEqual(result.locations[0], {id: 's', name: 'Station', disassembledName: 'Platform', type: 'stop'});
});

test('request allowlist rejects SSRF, credentials and excessive filtering', () => {
  for (const url of ['http://localhost/private', 'https://api.transport.nsw.gov.au.evil/v1/tp/trip', 'https://api.transport.nsw.gov.au/admin', `${source.url}?api_key=private`]) {
    assert.throws(() => parseRequest({version: 1, url}));
  }
  assert.throws(() => parseRequest({version: 1, url: source.url, filter: {tripIds: Array(101).fill('a')}}));
  assert.equal(parseRequest({version: 1, url: source.url}).ttlMs, 30_000);
});

test('delta feeds and malformed provider bodies are never installed', () => {
  const delta = Buffer.from(Feed.encode(Feed.create({header: {gtfsRealtimeVersion: '2.0', incrementality: 1}, entity: []})).finish());
  assert.throws(() => project(delta, 'realtime', {}));
  assert.throws(() => project(Buffer.from('{}'), 'stops', {}));
});

test('viewport projection retains only visible vehicles including date line bounds', () => {
  const bytes = encode([
    {id: 'near', vehicle: {vehicle: {id: 'v1'}, position: {latitude: -33.8, longitude: 151.2}}},
    {id: 'far', vehicle: {vehicle: {id: 'v2'}, position: {latitude: -37.8, longitude: 145}}},
    {id: 'date-line', vehicle: {vehicle: {id: 'v3'}, position: {latitude: 0, longitude: 179}}},
  ]);
  const result = Feed.decode(project(bytes, 'realtime', {bounds: [-34, 151, -33, 152]}).bytes);
  assert.deepEqual(result.entity.map(e => e.id), ['near']);
  assert.deepEqual(Feed.decode(project(bytes, 'realtime', {bounds: [-1, 170, 1, -170]}).bytes).entity.map(e => e.id), ['date-line']);
  assert.deepEqual(Feed.decode(project(bytes, 'realtime', {vehicleId: 'v2'}).bytes).entity.map(e => e.id), ['far']);
  assert.throws(() => parseRequest({version: 1, url: source.url, filter: {bounds: [0, 0, 91, 1]}}));
});

test('indexed queries never mutate the shared snapshot for subsequent users', () => {
  const bytes = encode([
    {id: 'a', tripUpdate: {trip: trip('a', '20261027')}},
    {id: 'b', tripUpdate: {trip: trip('b', '20261027')}},
  ]);
  const projectIds = filter => Feed.decode(project(bytes, 'realtime', filter, 'test-generation').bytes).entity.map(e => e.id);
  assert.deepEqual(projectIds({tripIds: ['a']}), ['a']);
  assert.deepEqual(projectIds({tripIds: ['b']}), ['b']);
  assert.deepEqual(projectIds({}), ['a', 'b']);
});
