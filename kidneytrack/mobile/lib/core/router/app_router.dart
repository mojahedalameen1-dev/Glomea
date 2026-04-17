import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../layout/web_shell.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/onboarding/screens/onboarding_screen_1.dart';
import '../../features/onboarding/screens/onboarding_screen_2.dart';
import '../../features/intro/intro_screen.dart';
import '../../features/auth/auth_gateway_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/lab_entry/lab_entry_screen.dart';
import '../../features/daily_entry/daily_entry_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/lab_entry/screens/lab_review_screen.dart';
import '../../features/alerts/alerts_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../widgets/layout/bottom_nav_shell.dart';
import '../../features/potassium_scanner/screens/food_search_screen.dart';
import '../../features/potassium_scanner/screens/barcode_scanner_screen.dart';
import '../../features/medications/screens/medications_screen.dart';
import '../../features/medications/screens/add_medication_screen.dart';
import '../../features/dashboard/web_dashboard_screen.dart';

final initialLocationProvider = Provider<String>((ref) => '/auth-gateway');

final routerProvider = Provider<GoRouter>((ref) {
  final initialLocation = ref.watch(initialLocationProvider);
  return AppRouter.createRouter(ref, initialLocation: initialLocation);
});

class AppRouter {
  static const login = '/login';
  static const register = '/register';
  static const intro = '/intro';
  static const authGateway = '/auth-gateway';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const labEntry = '/lab-entry';
  static const dailyEntry = '/daily_entry';
  static const history = '/history';
  static const historyWithCode = '/history/:indicatorCode';
  static const alerts = '/alerts';
  static const profile = '/profile';
  static const foodSearch = '/food-search';
  static const barcodeScanner = '/barcode-scanner';
  static const medications = '/medications';
  static const addMedication = '/add-medication';
  static const labReview = '/lab-review';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(Ref ref, {String initialLocation = authGateway}) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: initialLocation,
      refreshListenable: _RouterNotifier(ref),
      redirect: (context, state) {
        final location = state.matchedLocation;
        final session = Supabase.instance.client.auth.currentSession;
        final isLoggedIn = session != null;
        debugPrint('Router CHECK: location=$location, isLoggedIn=$isLoggedIn');

        final isOnAuth = location == login ||
            location == register ||
            location == intro ||
            location == authGateway;

        final isOnBoarding = location.contains('/onboarding');

        // 1. No session — redirect to login unless already on auth screens
        if (!isLoggedIn) {
          if (isOnAuth) return null;
          debugPrint('Router: No session, redirecting to login');
          return login;
        }

        // 2. Session exists — watch (not read) so redirect re-evaluates on change
        final authAsync = ref.watch(authNotifierProvider);
        if (authAsync.isLoading) {
          debugPrint('Router: Auth state loading, skipping redirect');
          return null;
        }

        if (isOnAuth || isOnBoarding) {
          final patient = authAsync.valueOrNull;
          final bool isOnboarded = patient?.onboardingComplete ??
              (session.user.userMetadata?['onboarding_complete'] == true);

          debugPrint('Router: isOnboarded=$isOnboarded, location=$location');

          if (!isOnboarded) {
            if (isOnBoarding) {
              debugPrint('Router: User not onboarded, allowing onboarding route');
              return null;
            }
            debugPrint('Router: User not onboarded, forcing step1');
            return '$onboarding/step1';
          }

          debugPrint('Router: User onboarded, redirecting to dashboard');
          return dashboard;
        }

        return null;
      },
      routes: [
        GoRoute(path: intro, builder: (context, state) => const IntroScreen()),
        GoRoute(path: authGateway, builder: (context, state) => const AuthGatewayScreen()),
        GoRoute(path: login, builder: (context, state) => const LoginScreen()),
        GoRoute(path: register, builder: (context, state) => const RegisterScreen()),

        GoRoute(
          path: onboarding,
          redirect: (context, state) =>
              state.matchedLocation == onboarding ? '$onboarding/step1' : null,
          routes: [
            GoRoute(
              path: 'step1',
              builder: (context, state) => const OnboardingScreen1(),
            ),
            GoRoute(
              path: 'step2',
              builder: (context, state) => const OnboardingScreen2(),
            ),
          ],
        ),

        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => kIsWeb
              ? WebShell(navigationShell: navigationShell)
              : BottomNavShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: dashboard,
                  builder: (context, state) =>
                      kIsWeb ? const WebDashboardScreen() : const DashboardScreen(),
                )
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: history,
                  builder: (context, state) {
                    final search = state.uri.queryParameters['search'];
                    return HistoryScreen(searchQuery: search);
                  },
                  routes: [
                    GoRoute(
                      path: ':indicatorCode',
                      builder: (context, state) {
                        final code = state.pathParameters['indicatorCode'];
                        return HistoryScreen(indicatorCode: code);
                      },
                    ),
                  ],
                )
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: alerts, builder: (context, state) => const AlertsScreen())
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: medications, builder: (context, state) => const MedicationsScreen())
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: profile, builder: (context, state) => const ProfileScreen())
              ],
            ),
          ],
        ),

        // Modal Entries
        GoRoute(
          path: labEntry,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LabEntryScreen(),
        ),
        GoRoute(
          path: dailyEntry,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const DailyEntryScreen(),
        ),
        GoRoute(
          path: foodSearch,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const FoodSearchScreen(),
        ),
        GoRoute(
          path: barcodeScanner,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const BarcodeScannerScreen(),
        ),
        GoRoute(
          path: addMedication,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AddMedicationScreen(),
        ),
        GoRoute(
          path: labReview,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return LabReviewScreen(
              extractedValues: extra['extractedValues'] as Map<String, double?>,
              rawText: extra['rawText'] as String,
              recordedAt: extra['recordedAt'] as DateTime,
            );
          },
        ),
      ],
    );
  }
}

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    // Listen to auth state changes (login/logout)
    _ref.listen<AsyncValue<AuthState>>(authStateProvider, (_, __) {
      notifyListeners();
    });

    // Listen only to onboarding completion transition (false → true)
    _ref.listen<bool?>(
      authNotifierProvider.select((s) => s.valueOrNull?.onboardingComplete),
      (previous, next) {
        if (previous == false && next == true) {
          debugPrint('Router: Onboarding completed, triggering redirect');
          notifyListeners();
        }
      },
    );
  }
}
