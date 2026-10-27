import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/answer.dart';
import '../../models/assessment_area.dart';
import '../../models/checklist_item.dart';
import '../../providers/assessment_provider.dart';
import '../../strings.dart';
import '../../widgets/load_error_view.dart';
import 'checklist_item_card.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key, required this.areaId});

  final String areaId;

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  @override
  void initState() {
    super.initState();
    // Needed when this page is opened directly by URL on the web.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AssessmentProvider>().ensureLoaded(),
    );
  }

  Future<void> _answer(ChecklistItem item, AnswerValue value) async {
    final saved = await context.read<AssessmentProvider>().setAnswer(
      item,
      value,
    );
    if (!saved && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.errorSaveAnswer)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final area = AssessmentArea.byId(widget.areaId);

    return Scaffold(
      appBar: AppBar(title: Text(area?.name ?? AppStrings.assessmentAreas)),
      body: area == null
          ? const Center(child: Text(AppStrings.areaNotFound))
          : _buildBody(context.watch<AssessmentProvider>(), area),
    );
  }

  Widget _buildBody(AssessmentProvider assessment, AssessmentArea area) {
    final error = assessment.errorMessage;
    if (error != null) {
      return LoadErrorView(message: error, onRetry: assessment.ensureLoaded);
    }
    if (!assessment.isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = assessment.itemsForArea(area.id);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return ChecklistItemCard(
              item: item,
              answer: assessment.answerFor(item.id),
              onAnswer: (value) => _answer(item, value),
            );
          },
        ),
      ),
    );
  }
}
