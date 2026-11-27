import assert from 'node:assert/strict';
import test from 'node:test';
import { createTransitCacheHandler } from '../src/handler.js';
import sources from '../src/provider-sources.json' with { type: 'json' };

const fetchedAt = Date.UTC(2026, 0, 1);
const expiresAt = fetchedAt + 30_000;
const stopRequest = {
  version: 1,
  url: 'https://api.transport.nsw.gov.au/v1/tp/stop_finder?outputFormat=rapidJSON',
};

async function invoke(resolve, request) {
  const response = {
    headers: {},
    set(name, value) {
      if (typeof name === 'string') this.headers[name] = value;
      else Object.assign(this.headers, name);
      return this;
    },
    status(code) {
      this.statusCode = code;
      return this;
    },
    send(body) {
      this.body = body;
    },
  };
  await createTransitCacheHandler(resolve)(request, response);
  return response;
}

test('requests rejected at the HTTP boundary never reach the resolver', async () => {
  const resolve = () => assert.fail('Unexpected cache lookup');
  assert.equal((await invoke(resolve, {method: 'GET'})).statusCode, 405);
  assert.equal((await invoke(resolve, {method: 'POST', body: {}})).statusCode, 400);
});

test('valid stop requests return projected JSON and snapshot metadata', async () => {
  const response = await invoke(async source => {
    assert.equal(source.kind, 'stops');
    const locations = [{id: 'central', name: 'Central', extra: true}];
    return {bytes: Buffer.from(JSON.stringify({locations})), fetchedAt, expiresAt};
  }, {method: 'POST', body: stopRequest});

  assert.equal(response.statusCode, 200);
  assert.deepEqual(JSON.parse(response.body), {
    locations: [{id: 'central', name: 'Central'}],
  });
  assert.equal(response.headers['Content-Type'], 'application/json');
  assert.equal(response.headers['Cache-Control'], 'no-store');
  assert.equal(response.headers['X-Transit-Version'], '1');
  assert.equal(response.headers['X-Transit-Fetched-At'], new Date(fetchedAt).toISOString());
  assert.equal(response.headers['X-Transit-Expires-At'], new Date(expiresAt).toISOString());
});

test('published static archives return a download pointer and no inline bytes', async () => {
  const downloadUrl = 'https://example.com/feed.zip';
  const url = sources.find(source => source.kind === 'static').url;
  const response = await invoke(async source => {
    assert.equal(source.kind, 'static');
    return {downloadUrl, fetchedAt, expiresAt};
  }, {method: 'POST', body: {version: 1, url}});

  assert.equal(response.statusCode, 200);
  assert.equal(response.headers['Content-Type'], 'application/zip');
  assert.equal(response.headers['X-Transit-Download-Url'], downloadUrl);
  assert.ok(response.headers['Access-Control-Expose-Headers'].split(', ')
    .includes('X-Transit-Download-Url'));
  assert.equal(response.body.length, 0);
});

test('a malformed cached snapshot returns unavailable without success headers', async () => {
  const response = await invoke(async () => ({
    bytes: Buffer.from('{"locations": null}'),
    fetchedAt: fetchedAt + 1_000,
    expiresAt: expiresAt + 1_000,
  }), {method: 'POST', body: stopRequest});

  assert.equal(response.statusCode, 503);
  assert.equal(response.body, 'Shared transit data unavailable');
  assert.deepEqual(response.headers, {});
});

test('resolver failures return a generic unavailable response', async () => {
  const response = await invoke(async () => {
    throw new Error('Internal provider error');
  }, {method: 'POST', body: stopRequest});

  assert.equal(response.statusCode, 503);
  assert.equal(response.body, 'Shared transit data unavailable');
});
