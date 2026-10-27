import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/action_provider.dart';
import 'providers/assessment_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/guide_chat_provider.dart';
import 'providers/school_provider.dart';
import 'router.dart';
import 'strings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AccessPathApp());
}

class AccessPathApp extends StatefulWidget {
  const AccessPathApp({super.key});

  @override
  State<AccessPathApp> createState() => _AccessPathAppState();
}

class _AccessPathAppState extends State<AccessPathApp> {
  // Created once here (not in build) so rebuilds do not reset navigation.
  final _authProvider = AuthProvider();
  late final GoRouter _router = buildRouter(_authProvider);

  @override
  void dispose() {
    _router.dispose();
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        // Login -> school lookup -> the school's data. Each step starts
        // loading by itself when the one before it is ready.
        ChangeNotifierProxyProvider<AuthProvider, SchoolProvider>(
          create: (_) => SchoolProvider(),
          update: (_, auth, school) => school!..setUser(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<SchoolProvider, AssessmentProvider>(
          create: (_) => AssessmentProvider(),
          update: (_, school, assessment) =>
              assessment!..setSchool(school.schoolId, school.uid),
        ),
        ChangeNotifierProxyProvider<SchoolProvider, ActionProvider>(
          create: (_) => ActionProvider(),
          update: (_, school, actions) => actions!..setSchool(school.schoolId),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GuideChatProvider>(
          create: (_) => GuideChatProvider(),
          update: (_, auth, chat) => chat!..setUser(auth.user?.uid),
        ),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: appTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
