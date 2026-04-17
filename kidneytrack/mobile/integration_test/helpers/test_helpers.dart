import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kidneytrack_mobile/main.dart' as app;

class TestHelpers {
  static Future<void> setupTest() async {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  }

  static Future<void> startApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
  }

  static Future<void> waitForSplash(WidgetTester tester) async {
    // Splash waits ~4 seconds (3500ms + animations)
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  static Future<void> swipeIntro(WidgetTester tester) async {
    // There are 3 steps in IntroScreen
    for (int i = 0; i < 2; i++) {
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle(const Duration(milliseconds: 800));
    }
    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();
  }

  static Future<void> enterText(
      WidgetTester tester, String label, String value) async {
    // Fallback if the above complex finder fails, try to find by hint or label directly
    // Since AppTextField has the label above the TextFormField
    await tester.enterText(
        find.byType(TextFormField).at(0), value); // This is risky, let's refine
  }

  // Refined way to find TextFormField by label in AppTextField
  static Finder findFieldByLabel(String label) {
    return find.ancestor(
      of: find.byType(TextFormField),
      matching: find.ancestor(
        of: find.text(label),
        matching: find.byType(Column),
      ),
    );
  }

  static Future<void> fillField(
      WidgetTester tester, String label, String value) async {
    final field = find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(Column)),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(field, value);
    await tester.pumpAndSettle();
  }

  static Future<void> tapButton(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }
}
