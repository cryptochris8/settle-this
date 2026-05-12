import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settle_this/app/settle_this_app.dart';
import 'package:settle_this/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Fresh launch routes to onboarding', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SettleThisApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Settle silly arguments'),
      findsOneWidget,
      reason: 'First page of OnboardingScreen should be visible',
    );
  });

  testWidgets('Completed onboarding state lands on age gate', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding_complete': true,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SettleThisApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('How old are you?'), findsOneWidget);
  });
}
