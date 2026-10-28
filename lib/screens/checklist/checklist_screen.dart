import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../page_text.dart';
import '../../models/answer.dart';
import '../../models/assessment_area.dart';
import '../../models/checklist_item.dart';
import '../../providers/assessment_provider.dart';
import '../../router.dart';
import '../../strings.dart';
import '../../widgets/data_gate.dart';
import '../../widgets/page_scaffold.dart';
import 'checklist_item_card.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key, required this.areaId});

  final String areaId;

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
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

    return PageScaffold(
      title: area?.name ?? AppStrings.assessmentAreas,
      description: PageText.assess,
      body: area == null
          ? const Center(child: Text(AppStrings.areaNotFound))
          : DataGate(
              builder: (context) =>
                  _buildBody(context.watch<AssessmentProvider>(), area),
            ),
    );
  }

  Widget _buildBody(AssessmentProvider assessment, AssessmentArea area) {
    final items = assessment.itemsForArea(area.id);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          // The first row is the "check a photo" button for the whole area.
          itemCount: items.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return FilledButton.tonalIcon(
                onPressed: () => context.go(AppRoutes.photoCheck(area.id)),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text(AppStrings.checkPhotoOfArea),
              );
            }
            final item = items[index - 1];
            return ChecklistItemCard(
              item: item,
              answer: assessment.answerFor(item.id),
              onAnswer: (value) => _answer(item, value),
              onPhotoCheck: () =>
                  context.go(AppRoutes.photoCheck(area.id, itemId: item.id)),
            );
          },
        ),
      ),
    );
  }
}
