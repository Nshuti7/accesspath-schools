import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/actions/action_tracker_screen.dart';
import 'screens/actions/assign_action_screen.dart';
import 'screens/areas/areas_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/checklist/checklist_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/gaps/gap_report_screen.dart';
import 'screens/photo_check/photo_check_screen.dart';
import 'screens/school/school_profile_screen.dart';
import 'widgets/app_shell.dart';

class AppRoutes {
  static const login = '/login';
  static const signUp = '/sign-up';
  static const dashboard = '/';
  static const areas = '/areas';
  static const gaps = '/gaps';
  static const actions = '/actions';
  static const schoolProfile = '/school';
  static String assignAction(String gapId) => '/gaps/$gapId/assign';
  static String checklist(String areaId) => '/areas/$areaId';

  /// With [itemId], the photo is checked against that one item only.
  static String photoCheck(String areaId, {String? itemId}) {
    final path = '/areas/$areaId/photo';
    return itemId == null ? path : '$path?item=$itemId';
  }
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
      // Every signed-in page sits inside the shell, so the navigation bar or
      // rail stays visible. Sub-pages are nested so the back arrow works.
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.areas,
            builder: (context, state) => const AreasScreen(),
            routes: [
              GoRoute(
                path: ':areaId',
                builder: (context, state) =>
                    ChecklistScreen(areaId: state.pathParameters['areaId']!),
                routes: [
                  GoRoute(
                    path: 'photo',
                    builder: (context, state) => PhotoCheckScreen(
                      areaId: state.pathParameters['areaId']!,
                      itemId: state.uri.queryParameters['item'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.gaps,
            builder: (context, state) => const GapReportScreen(),
            routes: [
              GoRoute(
                path: ':gapId/assign',
                builder: (context, state) =>
                    AssignActionScreen(gapId: state.pathParameters['gapId']!),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.actions,
            builder: (context, state) => const ActionTrackerScreen(),
          ),
          GoRoute(
            path: AppRoutes.schoolProfile,
            builder: (context, state) => const SchoolProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
