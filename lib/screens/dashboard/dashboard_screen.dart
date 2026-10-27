import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../router.dart';
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Dashboard coming soon'),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.areas),
                icon: const Icon(Icons.checklist),
                label: const Text(AppStrings.startAssessment),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
