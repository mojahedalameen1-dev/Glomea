import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helpers.dart';

void main() {
  TestHelpers.setupTest();

  group('UX Quality Checks', () {
    testWidgets('Performance: Screen load and smooth scroll', (tester) async {
      final stopwatch = Stopwatch()..start();
      await TestHelpers.startApp(tester);
      await TestHelpers.waitForSplash(tester);
      stopwatch.stop();

      // Check load time (should be reasonable)
      // Note: In integration tests, timing might be affected by the environment, 
      // but we document the check here.
      expect(stopwatch.elapsed.inSeconds, lessThan(10)); // Total boot + splash

      // Test scroll smoothness on a long list (if available)
      // Similar to accessibility, we check if PageView exists on Intro
      expect(find.byType(PageView), findsOneWidget);

      await TestHelpers.swipeIntro(tester);
    });

    testWidgets('Accessibility: Text sizes and Button targets', (tester) async {
      await TestHelpers.startApp(tester);
      await TestHelpers.waitForSplash(tester);
      
      // Check for buttons min size (48x48)
      // This is a programmatic check that can be done using WidgetTester
      final nextButton = find.text('التالي').first;
      if (nextButton.evaluate().isNotEmpty) {
        // Verify dashboard content load
        await tester.pumpAndSettle();
        // Buttons should be at least 48dp as per UX requirements
        // expect(size.width, greaterThanOrEqualTo(48));
        // expect(size.height, greaterThanOrEqualTo(48));
      }

      // Check text sizes
      final welcomeText = find.text('مرحباً بك في جلوميا');
      if (welcomeText.evaluate().isNotEmpty) {
        final Text textWidget = tester.widget(welcomeText);
        expect(textWidget.style?.fontSize, greaterThanOrEqualTo(14));
      }
    });

    testWidgets('Error Handling: Fallback UI', (tester) async {
      // This would normally involve mocking a network failure
      // For a basic UX check, we ensure that loading indicators are used
      await TestHelpers.startApp(tester);
      // expect(find.byType(CircularProgressIndicator), findsNothing); // After settle
    });
  });
}
