// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lbww_flutter/main.dart';

void main() {
  group('NSW Trains Timetable App Tests', () {
    testWidgets('App loads and shows correct title', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that our app shows the correct title
      expect(find.text('NSW Trains Timetable'), findsOneWidget);
      
      // Verify that the settings icon is present
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Settings button navigates to settings screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Tap the settings button
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify that we've navigated to the settings screen
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Enter an API key'), findsOneWidget);
    });

    testWidgets('API key input field is present in settings', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify API key input components are present
      expect(find.text('Set API Key'), findsOneWidget);
      expect(find.text('Clear API Key'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
