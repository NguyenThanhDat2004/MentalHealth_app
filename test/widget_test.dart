// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart'; // ĐÃ SỬA LỖI

// Sửa lại tên package cho đúng với tên dự án của bạn
// (Tên package có thể xem trong file pubspec.yaml)
import 'package:mental_health_app/main.dart';
import 'package:mental_health_app/home_screen.dart';

void main() {
  testWidgets('App loads and displays the main screen with HomeScreen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Sửa lại tên class từ MyApp thành MentalHealthApp
    await tester.pumpWidget(const MentalHealthApp());

    // Xác minh rằng MainScreen (chứa BottomNavBar) được hiển thị.
    expect(find.byType(MainScreen), findsOneWidget);

    // Xác minh rằng HomeScreen được hiển thị mặc định khi app khởi động.
    expect(find.byType(HomeScreen), findsOneWidget);

    // Xác minh rằng BottomNavigationBar có mặt.
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Xác minh rằng icon Home được hiển thị.
    expect(find.byIcon(Icons.home), findsOneWidget);
  });
}
