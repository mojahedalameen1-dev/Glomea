import 'package:flutter_test/flutter_test.dart';
import 'helpers/mock_data.dart';
import 'helpers/test_helpers.dart';

void main() {
  TestHelpers.setupTest();

  group('Doctor Journey Test', () {
    testWidgets('Doctor Login and Dashboard', (tester) async {
      await TestHelpers.startApp(tester);
      await TestHelpers.waitForSplash(tester);
      await TestHelpers.swipeIntro(tester);

      // Go to Login
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      // Switch to Admin/Doctor Login link
      await tester.tap(find.text('تسجيل دخول المسؤولين (Admin)'));
      await tester.pumpAndSettle();

      // STEP 1 — Login كطبيب
      await TestHelpers.fillField(
          tester, 'البريد الإلكتروني', MockData.doctorEmail);
      await TestHelpers.fillField(
          tester, 'كلمة المرور', MockData.doctorPassword);

      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // STEP 2 — Doctor Dashboard
      // Check if redirected to Admin Dashboard
      expect(find.text('نظرة عامة على النظام'), findsOneWidget);
      expect(find.text('المرضى الكلي'), findsOneWidget);
      expect(find.text('حالات حرجة'), findsOneWidget);

      // Appointments list (In this app, it's Recent Activity)
      expect(find.text('النشاط الأخير'), findsOneWidget);
    });
  });
}
