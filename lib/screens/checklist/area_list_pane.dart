import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../layout.dart';
import '../../models/assessment_area.dart';
import '../../providers/assessment_provider.dart';
import '../../strings.dart';
import '../../widgets/selectable_tile.dart';

/// Left side of the desktop checklist: every area with its progress, the
/// open one highlighted.
class AreaListPane extends StatelessWidget {
  const AreaListPane({
    super.key,
    required this.selectedAreaId,
    required this.onSelected,
  });

  final String selectedAreaId;
  final ValueChanged<AssessmentArea> onSelected;

  @override
  Widget build(BuildContext context) {
    final assessment = context.watch<AssessmentProvider>();
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.xs, Space.lg),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Space.xs),
          child: Semantics(
            header: true,
            child: Text(
              AppStrings.assessmentAreas,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        for (final area in AssessmentArea.all)
          Builder(
            builder: (context) {
              final total = assessment.itemsForArea(area.id).length;
              final answered = assessment.answeredCountForArea(area.id);
              return SelectableTile(
                icon: area.icon,
                label: area.name,
                isSelected: area.id == selectedAreaId,
                onTap: () => onSelected(area),
                semanticsHint: AppStrings.answeredOf(answered, total),
                below: LinearProgressIndicator(
                  value: total == 0 ? 0 : answered / total,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                trailing: Text(
                  '$answered/$total',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            },
          ),
      ],
    );
  }
}
