// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Giả sử tên project của bạn là 'mental_health_app'.
// Nếu khác, hãy thay thế 'mental_health_app' bằng tên đúng trong file pubspec.yaml.
import 'package:mental_health_app/main.dart';

void main() {
  testWidgets('App loads and displays the main screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MentalHealthApp());

    // Xác minh rằng màn hình chính (MainScreen) được hiển thị.
    expect(find.byType(MainScreen), findsOneWidget);

    // Xác minh rằng BottomNavigationBar có mặt.
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Xác minh rằng icon Home được hiển thị.
    expect(find.byIcon(Icons.home), findsOneWidget);
  });
}
