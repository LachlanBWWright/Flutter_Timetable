import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared UI does not import provider internals directly', () async {
    final root = Directory.current.path;
    final files = <String>[
      '$root/lib/main.dart',
      '$root/lib/new_trip.dart',
      '$root/lib/trip.dart',
      '$root/lib/settings.dart',
    ];

    final widgetsDir = Directory('$root/lib/widgets');
    if (await widgetsDir.exists()) {
      await for (final entity in widgetsDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          files.add(entity.path);
        }
      }
    }

    final forbiddenImport = RegExp(
      r"package:lbww_flutter\/(nsw|victoria|queensland)\/",
    );

    for (final path in files) {
      final file = File(path);
      if (!await file.exists()) {
        continue;
      }
      final content = await file.readAsString();
      expect(
        forbiddenImport.hasMatch(content),
        isFalse,
        reason: 'Provider implementation import found in $path',
      );
    }
  });
}
