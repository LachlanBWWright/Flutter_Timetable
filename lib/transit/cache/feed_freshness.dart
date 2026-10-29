import 'package:http/http.dart' as http;

final _times = Expando<DateTime>();

T rememberFeedFetch<T extends Object>(T feed, http.Response response) {
  _times[feed] =
      DateTime.tryParse(response.headers['x-transit-fetched-at'] ?? '') ??
      DateTime.now();
  return feed;
}

DateTime feedFetchedAt(Object? feed) =>
    feed == null ? DateTime.now() : _times[feed] ?? DateTime.now();
