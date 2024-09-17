import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice_1/main.dart'; // นำเข้าไฟล์หลักของแอปคุณ

void main() {
  testWidgets('ทดสอบว่าแอปทำงานหรือไม่', (WidgetTester tester) async {
    // แทนที่ MyApp ด้วย FlashlightApp
    await tester.pumpWidget(const FlashlightApp());

    // ทดสอบว่ามีการสร้าง widget ที่ต้องการหรือไม่
    expect(find.text('ไฟฉายแบบตึงๆ'), findsOneWidget);
  });
}
