import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../strings.dart';

/// Placeholder so the router has somewhere to send logged-in users.
/// Replace with the real dashboard in its own task.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          TextButton(
            onPressed: () => context.read<AuthProvider>().signOut(),
            child: const Text(AppStrings.logOut),
          ),
        ],
      ),
      body: const Center(child: Text('Dashboard coming soon')),
    );
  }
}
