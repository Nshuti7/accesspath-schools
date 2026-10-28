import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/answer.dart';
import '../../models/assessment_area.dart';
import '../../models/checklist_item.dart';
import '../../providers/assessment_provider.dart';
import '../../router.dart';
import '../../strings.dart';
import 'checklist_item_card.dart';

/// The questions for one area, answered in place. Used full-width on phones
/// and as the right-hand side of the desktop split view.
class ChecklistQuestionList extends StatelessWidget {
  const ChecklistQuestionList({
    super.key,
    required this.area,
    this.showPhotoButton = true,
    this.padding = const EdgeInsets.all(16),
  });

  final AssessmentArea area;

  /// Desktop shows this button in the page header instead.
  final bool showPhotoButton;
  final EdgeInsets padding;

  Future<void> _answer(
    BuildContext context,
    ChecklistItem item,
    AnswerValue value,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = await context.read<AssessmentProvider>().setAnswer(
      item,
      value,
    );
    if (!saved) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.errorSaveAnswer)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final assessment = context.watch<AssessmentProvider>();
    final items = assessment.itemsForArea(area.id);
    final offset = showPhotoButton ? 1 : 0;

    return ListView.separated(
      // A new list per area, so switching areas starts at the top.
      key: PageStorageKey(area.id),
      padding: padding,
      itemCount: items.length + offset,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (showPhotoButton && index == 0) {
          return FilledButton.tonalIcon(
            onPressed: () => context.go(AppRoutes.photoCheck(area.id)),
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text(AppStrings.checkPhotoOfArea),
          );
        }
        final item = items[index - offset];
        return ChecklistItemCard(
          item: item,
          answer: assessment.answerFor(item.id),
          onAnswer: (value) => _answer(context, item, value),
          onPhotoCheck: () =>
              context.go(AppRoutes.photoCheck(area.id, itemId: item.id)),
        );
      },
    );
  }
}
