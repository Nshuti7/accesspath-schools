import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/action_provider.dart';
import '../providers/assessment_provider.dart';
import '../providers/school_provider.dart';
import 'load_error_view.dart';

/// Shows a spinner until the school (and its assessment, and optionally its
/// actions) have loaded, or an error with a retry for whichever failed.
/// Every data screen wraps its content in this so they all behave the same.
class DataGate extends StatelessWidget {
  const DataGate({super.key, required this.builder, this.needsActions = false});

  final WidgetBuilder builder;
  final bool needsActions;

  @override
  Widget build(BuildContext context) {
    final school = context.watch<SchoolProvider>();
    final assessment = context.watch<AssessmentProvider>();
    final actions = context.watch<ActionProvider>();

    final failures = [
      (school.errorMessage, school.load),
      (assessment.errorMessage, assessment.load),
      if (needsActions) (actions.errorMessage, actions.load),
    ];
    for (final (message, retry) in failures) {
      if (message != null) {
        return LoadErrorView(message: message, onRetry: retry);
      }
    }

    final isReady =
        school.isReady &&
        assessment.isReady &&
        (!needsActions || actions.isReady);
    if (!isReady) return const Center(child: CircularProgressIndicator());
    return builder(context);
  }
}
