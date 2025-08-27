// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:restream_flutter_example/main.dart';

void main() {
  testWidgets('App loads configuration screen when not configured',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RestreamApp());

    // Wait for async initialization
    await tester.pumpAndSettle();

    // Verify that configuration screen appears
    expect(find.text('Restream Configuration'), findsOneWidget);
    expect(find.text('Client ID'), findsOneWidget);
  });
}
