import 'package:flutter/material.dart'; // แก้ไขการ import ของ Material เพื่อใช้ Key และ Icons
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:practice_1/main.dart';  // ปรับตามชื่อแพ็คเกจของคุณ

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ทดสอบการทำงานภาพรวมของแอป', (WidgetTester tester) async {
    // เปิดแอป
    await tester.pumpWidget(const FlashlightApp());

    // ตรวจสอบว่ามีข้อความ 'ไฟฉายแบบตึงๆ' แสดงหรือไม่
    expect(find.text('ไฟฉายแบบตึงๆ'), findsOneWidget);

    // กดปุ่มเปิดไฟฉายโดยใช้ Key
    final toggleTorchButton = find.byKey(const Key('toggle_torch'));
    await tester.tap(toggleTorchButton);
    await tester.pump();

    // ตรวจสอบสถานะของไฟฉายว่าถูกเปิด
    expect(find.byIcon(Icons.flash_on), findsOneWidget);

    // กดปุ่มสลับภาษา
    final languageButton = find.byIcon(Icons.language);
    await tester.tap(languageButton);
    await tester.pump();

    // ตรวจสอบว่าภาษาเปลี่ยนเป็นอังกฤษ
    expect(find.text('Flashlight App'), findsOneWidget);

    // กดปุ่มกลับไปที่หน้า 'About Me'
    final aboutButton = find.byIcon(Icons.person);
    await tester.tap(aboutButton);
    await tester.pumpAndSettle();

    // ตรวจสอบว่าหน้า 'About Me' แสดง
    expect(find.text('About Me'), findsOneWidget);

    // กลับไปยังหน้าหลัก
    final backButton = find.text('🏠 Home');
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // ตรวจสอบว่ากลับไปที่หน้าหลักแล้ว
    expect(find.text('Flashlight App'), findsOneWidget);
  });
}
