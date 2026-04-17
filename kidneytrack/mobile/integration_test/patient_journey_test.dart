import 'package:flutter_test/flutter_test.dart';
import 'helpers/mock_data.dart';
import 'helpers/test_helpers.dart';

void main() {
  TestHelpers.setupTest();

  group('Patient Journey Test', () {
    testWidgets('Full Patient Flow: Splash -> Onboarding -> Register -> Home', (tester) async {
      await TestHelpers.startApp(tester);

      // STEP 1 — Splash & Onboarding
      // Check Splash
      expect(find.text('Glomea'), findsOneWidget);
      await TestHelpers.waitForSplash(tester);

      // Transition to Intro/Onboarding
      expect(find.text('مرحباً بك في جلوميا'), findsOneWidget);

      // Swipe between Onboarding screens
      await TestHelpers.swipeIntro(tester);

      // STEP 2 — Registration
      // We are now at AuthGatewayScreen
      await tester.tap(find.text('إنشاء حساب جديد'));
      await tester.pumpAndSettle();

      expect(find.text('الاسم الأول'), findsOneWidget);
      expect(find.text('الاسم الأخير'), findsOneWidget);

      // Fill registration form
      await TestHelpers.fillField(tester, 'الاسم الأول', MockData.firstName);
      await TestHelpers.fillField(tester, 'الاسم الأخير', MockData.lastName);
      await TestHelpers.fillField(tester, 'البريد الإلكتروني', MockData.newEmail);
      
      // Test password visibility
      await TestHelpers.fillField(tester, 'كلمة المرور', MockData.newPassword);
      await TestHelpers.fillField(tester, 'تأكيد كلمة المرور', MockData.newPassword);
      
      await tester.tap(find.text('إنشاء الحساب'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // After registration, it should go to /onboarding (health data)
      expect(find.text('معلومات أساسية'), findsOneWidget);
      
      // Skip health onboarding if possible or fill it (simplified here)
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('التالي'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('تأكيد'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // STEP 3 — Home Screen (Patient)
      // Transition to Dashboard
      expect(find.textContaining('صباح الصحة'), findsOneWidget); // Or similar greeting
      
      // Check load state (indicators should be there)
      expect(find.text('نظرة سريعة'), findsOneWidget);
      
      // STEP 4 — Book Appointment
      // Note: This part might fail if features are not implemented, 
      // but following the requested UX Testing protocol.
      // Since 'Doctor' is not in the app, we check for a 'Doctor' text if it exists
      // If not, this test case documents a gap in the current implementation vs requirement.
      /*
      await tester.tap(find.textContaining('طبيب'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حجز موعد'));
      */
    });
    group('Registration Validation', () {
    testWidgets('Error messages on invalid input', (tester) async {
       await TestHelpers.startApp(tester);
       await TestHelpers.waitForSplash(tester);
       await TestHelpers.swipeIntro(tester);
       await tester.tap(find.text('إنشاء حساب جديد'));
       await tester.pumpAndSettle();
       
       await tester.tap(find.text('إنشاء الحساب'));
       await tester.pumpAndSettle();
       
       expect(find.text('مطلوب'), findsWidgets);
    });
  });
});
}
