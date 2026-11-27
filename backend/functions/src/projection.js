import protobuf from 'protobufjs';
import {providerSource} from './providers.js';
import { fileURLToPath } from 'node:url';
import sources from './sources.json' with { type: 'json' };

const root = protobuf.loadSync(fileURLToPath(new URL('./gtfs-realtime.proto', import.meta.url)));
export const Feed = root.lookupType('transit_realtime.FeedMessage');
const realtimeSources = new Set(sources);

export function parseRequest(body) {
  if (body?.version !== 1 || typeof body.url !== 'string' || body.url.length > 4096) throw new Error('Invalid request');
  const url = new URL(body.url);
  if (url.protocol !== 'https:' || url.username || url.password || url.hash || url.port) throw new Error('Unsupported source');
  let kind;
  let ttlMs;
  let provider;
  const registered = providerSource(url);
  if (registered) ({kind, ttlMs, provider} = registered);
  else if (realtimeSources.has(url.href)) { kind = 'realtime'; ttlMs = 30_000; provider = 'tfnsw'; }
  else if (url.origin === 'https://api.transport.nsw.gov.au' && ['/v1/tp/stop_finder', '/v1/tp/trip'].includes(url.pathname)) {
    provider = 'tfnsw';
    kind = url.pathname.endsWith('stop_finder') ? 'stops' : 'journeys';
    ttlMs = kind === 'stops' ? 3_600_000 : 30_000;
    // The backend owns provider credentials. Never cache credential-bearing URLs.
    for (const key of url.searchParams.keys()) {
      if (/key|token|signature|authorization|callback/i.test(key)) throw new Error('Unsupported parameter');
    }
    if (url.searchParams.get('outputFormat') !== 'rapidJSON' && url.searchParams.get('outputFormat') !== 'rapidjson') throw new Error('JSON output required');
    url.searchParams.sort();
  } else throw new Error('Unsupported source');
  const filter = body.filter ?? {};
  if (!filter || typeof filter !== 'object' || Array.isArray(filter) || Object.keys(filter).some(k => !['tripIds', 'routeId', 'vehicleId', 'bounds'].includes(k))) throw new Error('Invalid filter');
  if (filter.tripIds !== undefined && (!Array.isArray(filter.tripIds) || filter.tripIds.length > 100 || filter.tripIds.some(id => typeof id !== 'string' || !id || id.length > 256))) throw new Error('Invalid trip IDs');
  if (filter.routeId !== undefined && (typeof filter.routeId !== 'string' || !filter.routeId || filter.routeId.length > 256)) throw new Error('Invalid route');
  if (filter.vehicleId !== undefined && (typeof filter.vehicleId !== 'string' || !filter.vehicleId || filter.vehicleId.length > 256)) throw new Error('Invalid vehicle');
  if (filter.bounds !== undefined && (!Array.isArray(filter.bounds) || filter.bounds.length !== 4 || filter.bounds.some(v => !Number.isFinite(v)) || filter.bounds[0] < -90 || filter.bounds[2] > 90 || filter.bounds[0] > filter.bounds[2] || Math.abs(filter.bounds[1]) > 180 || Math.abs(filter.bounds[3]) > 180)) throw new Error('Invalid bounds');
  if (kind !== 'realtime'  && Object.keys(filter).length) throw new Error('Unsupported filter');
  url.searchParams.sort();
  return {url: url.href, provider, kind, ttlMs, filter};
}

export function validateSource(bytes, kind) {
  if (kind === 'static') {
    // Validate the container without inflating a potentially large ZIP on every
    // shared lookup. Existing device parsers still validate GTFS table content.
    if (bytes.length < 22 || bytes.readUInt32LE(0) !== 0x04034b50) throw new Error('ZIP required');
    const end = bytes.lastIndexOf(Buffer.from([0x50, 0x4b, 0x05, 0x06]));
    if (end < Math.max(0, bytes.length - 65_557) || end + 22 > bytes.length || end + 22 + bytes.readUInt16LE(end + 20) !== bytes.length) throw new Error('Incomplete ZIP');
    return bytes;
  }
  if (kind === 'realtime') {
    const feed = Feed.decode(bytes);
    if (!feed.header?.gtfsRealtimeVersion || feed.header.incrementality === 1) throw new Error('Full realtime snapshot required');
    return feed;
  }
  const body = JSON.parse(bytes.toString('utf8'));
  const field = ({stops: 'locations', journeys: 'journeys', ptvStops: 'stops', ptvStop: 'stop', ptvDepartures: 'departures', ptvDisruptions: 'disruptions'})[kind];
  if (kind === 'ptvStop' || kind === 'ptvDisruptions') {
    if (!body || !body[field] || typeof body[field] !== 'object' || Array.isArray(body[field])) throw new Error('Incomplete PTV response');
    return body;
  }
  if (!body || !Array.isArray(body[field])) throw new Error('Incomplete provider response');
  return body;
}

// Optional instance acceleration only; Firestore/Storage remain authoritative.
// Entries reference immutable decoded snapshots and are bounded by count/bytes.
const prepared = new Map();
function prepare(bytes, kind, generation) {
  if (generation && prepared.has(generation)) return prepared.get(generation);
  const decoded = validateSource(bytes, kind);
  const indexes = {trips: new Map(), routes: new Map(), vehicles: new Map()};
  if (kind === 'realtime') {
    for (const entity of decoded.entity) {
      const trip = entity.vehicle?.trip ?? entity.tripUpdate?.trip;
      const selectors = entity.alert?.informedEntity ?? [];
      for (const [map, id] of [[indexes.trips, trip?.tripId], [indexes.routes, trip?.routeId], [indexes.vehicles, entity.vehicle?.vehicle?.id],
          ...selectors.flatMap(selector => [[indexes.trips, selector.trip?.tripId], [indexes.routes, selector.routeId]])]) {
        if (!id) continue;
        if (!map.has(id)) map.set(id, []);
        if (!map.get(id).includes(entity)) map.get(id).push(entity);
      }
    }
  }
  const result = {decoded, indexes, size: bytes.length};
  if (generation && bytes.length <= 16 * 1024 * 1024) {
    prepared.set(generation, result);
    while (prepared.size > 4 || [...prepared.values()].reduce((sum, p) => sum + p.size, 0) > 16 * 1024 * 1024) {
      prepared.delete(prepared.keys().next().value);
    }
  }
  return result;
}

export function project(bytes, kind, filter, generation) {
  if (kind === 'static') { validateSource(bytes, kind); return {bytes, contentType: 'application/zip'}; }
  const {decoded, indexes} = prepare(bytes, kind, generation);
  if (kind === 'realtime') {
    if (!Object.keys(filter).length) return {bytes, contentType: 'application/x-protobuf'};
    const ids = new Set(filter.tripIds ?? []);
    let candidates = decoded.entity;
    if (ids.size) candidates = [...new Set([...ids].flatMap(id => indexes.trips.get(id) ?? []))];
    else if (filter.vehicleId) candidates = indexes.vehicles.get(filter.vehicleId) ?? [];
    else if (filter.routeId) candidates = indexes.routes.get(filter.routeId) ?? [];
    const selected = candidates.filter(entity => {
      const trip = entity.vehicle?.trip ?? entity.tripUpdate?.trip;
      if (!ids.size && filter.routeId && trip?.routeId !== filter.routeId && !entity.alert?.informedEntity.some(selector => selector.routeId === filter.routeId)) return false;
      if (filter.vehicleId && entity.vehicle?.vehicle?.id !== filter.vehicleId) return false;
      if (filter.bounds) {
        const p = entity.vehicle?.position;
        if (!p || !Object.hasOwn(p, 'latitude') || !Object.hasOwn(p, 'longitude')) return false;
        const [south, west, north, east] = filter.bounds;
        if (p.latitude < south || p.latitude > north) return false;
        if (west <= east ? p.longitude < west || p.longitude > east : p.longitude < west && p.longitude > east) return false;
      }
      return true;
    });
    // Retain descriptor dates/times, complete stop sequences and feed timestamps.
    // Do not mutate a shared snapshot when projecting one user's query.
    return {bytes: selectRawEntities(bytes, decoded.entity, new Set(selected)), contentType: 'application/x-protobuf'};
  }
  if (kind === 'stops') {
    return {bytes: Buffer.from(JSON.stringify({...decoded, locations: decoded.locations.map(({id, name, disassembledName, type}) => ({id, name, disassembledName, type}))})), contentType: 'application/json'};
  }
  if (kind === 'ptvStops') {
    return jsonResult({status: decoded.status, stops: decoded.stops.map(stop => pick(stop, ['stop_id', 'route_type', 'stop_name', 'stop_latitude', 'stop_longitude', 'stop_suburb', 'stop_landmark']))});
  }
  if (kind === 'ptvStop') {
    return jsonResult({status: decoded.status, stop: pick(decoded.stop, ['stop_id', 'stop_name', 'stop_landmark', 'station_description', 'stop_location'])});
  }
  if (kind === 'ptvDepartures') {
    const departures = decoded.departures.map(row => pick(row, ['route_id', 'run_id', 'direction_id', 'platform_number', 'scheduled_departure_utc', 'estimated_departure_utc', 'flags', 'departure_note']));
    const referenced = (map, field) => Object.fromEntries(departures.filter(row => row[field] != null && map?.[row[field]] != null).map(row => [row[field], map[row[field]]]));
    return jsonResult({status: decoded.status, departures, routes: referenced(decoded.routes, 'route_id'), runs: referenced(decoded.runs, 'run_id'), directions: referenced(decoded.directions, 'direction_id')});
  }
  if (kind === 'ptvDisruptions') {
    const disruptions = Object.fromEntries(Object.entries(decoded.disruptions).filter(([, rows]) => Array.isArray(rows)).map(([mode, rows]) => [mode, rows.map(row => pick(row, ['disruption_id', 'title', 'description', 'disruption_status']))]));
    return jsonResult({status: decoded.status, disruptions});
  }
  // Journey raw fields are still used for matching and walking instructions.
  // Preserve these until callers migrate to an explicit summary/detail model.
  return {bytes: Buffer.from(JSON.stringify(decoded)), contentType: 'application/json'};
}

// Preserve provider extension fields and unknown protobuf fields, including
// Adelaide Metro extensions, by selecting whole original wire entities.
function selectRawEntities(bytes, entities, selected) {
  const reader = protobuf.Reader.create(bytes);
  const pieces = [];
  let entity = 0;
  while (reader.pos < reader.len) {
    const start = reader.pos;
    const tag = reader.uint32();
    reader.skipType(tag & 7);
    if ((tag >>> 3) !== 2 || selected.has(entities[entity++])) pieces.push(bytes.subarray(start, reader.pos));
  }
  return Buffer.concat(pieces);
}

function pick(row, fields) {return Object.fromEntries(fields.filter(field => row[field] !== undefined).map(field => [field, row[field]]));}
function jsonResult(value) {return {bytes: Buffer.from(JSON.stringify(value)), contentType: 'application/json'};}
