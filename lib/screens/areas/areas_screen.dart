import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/assessment_area.dart';
import '../../providers/assessment_provider.dart';
import '../../router.dart';
import '../../strings.dart';
import '../../widgets/load_error_view.dart';
import 'area_card.dart';

class AreasScreen extends StatefulWidget {
  const AreasScreen({super.key});

  @override
  State<AreasScreen> createState() => _AreasScreenState();
}

class _AreasScreenState extends State<AreasScreen> {
  @override
  void initState() {
    super.initState();
    // Loading notifies listeners, which is not allowed during the first build.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AssessmentProvider>().ensureLoaded(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.assessmentAreas)),
      body: _buildBody(context.watch<AssessmentProvider>()),
    );
  }

  Widget _buildBody(AssessmentProvider assessment) {
    final error = assessment.errorMessage;
    if (error != null) {
      return LoadErrorView(message: error, onRetry: assessment.ensureLoaded);
    }
    if (!assessment.isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: AssessmentArea.all.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final area = AssessmentArea.all[index];
            return AreaCard(
              area: area,
              itemCount: assessment.itemsForArea(area.id).length,
              answeredCount: assessment.answeredCountForArea(area.id),
              onTap: () => context.go(AppRoutes.checklist(area.id)),
            );
          },
        ),
      ),
    );
  }
}
