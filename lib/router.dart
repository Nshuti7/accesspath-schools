import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/areas/areas_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/checklist/checklist_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const signUp = '/sign-up';
  static const dashboard = '/';
  static const areas = '/areas';
  static String checklist(String areaId) => '/areas/$areaId';
}

GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    // Re-runs the redirect whenever the user logs in or out.
    refreshListenable: auth,
    redirect: (context, state) {
      final onAuthPage =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signUp;

      if (!auth.isLoggedIn && !onAuthPage) return AppRoutes.login;
      // Wait while sign-up is still saving the school, otherwise the user
      // lands on the dashboard before their school record exists.
      if (auth.isLoggedIn && onAuthPage && !auth.isBusy) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
        // Nested so the app bar back arrow returns Checklist -> Areas -> Dashboard.
        routes: [
          GoRoute(
            path: 'areas',
            builder: (context, state) => const AreasScreen(),
            routes: [
              GoRoute(
                path: ':areaId',
                builder: (context, state) =>
                    ChecklistScreen(areaId: state.pathParameters['areaId']!),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
