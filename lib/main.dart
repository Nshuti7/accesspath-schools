import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
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
    return ChangeNotifierProvider.value(
      value: _authProvider,
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: appTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
