// ignore_for_file: catch_async_error_sources, catch_inferred_throwing_calls, catch_runtime_throw_sources, catch_unknown_dynamic_calls, no_null_assertion

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/fetch_data/fetch_timetable.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  test(
    'fetchTimetable returns a non-null Map on success',
    () async {
      final timetable = await fetchTimetable();
      expect(
        timetable,
        isNotNull,
        reason:
            'Timetable should not be null if API key and endpoint are valid',
      );
      expect(timetable, isA<Map<String, dynamic>>());
    },
    skip: 'Requires live API key',
  );
}
