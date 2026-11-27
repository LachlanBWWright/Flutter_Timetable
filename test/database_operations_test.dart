import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/schema/database_errors.dart';

void main() {
  test(
    'database operations wrap failures in DatabaseOperationFailure',
    () async {
      final database = AppDatabase.connect(NativeDatabase.memory());
      await database.close();

      expectLater(
        database.getAllJourneys(),
        throwsA(isA<DatabaseOperationFailure>()),
      );
    },
  );
}
