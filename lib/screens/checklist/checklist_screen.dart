import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../layout.dart';
import '../../models/assessment_area.dart';
import '../../page_text.dart';
import '../../router.dart';
import '../../strings.dart';
import '../../widgets/data_gate.dart';
import '../../widgets/page_scaffold.dart';
import 'area_list_pane.dart';
import 'checklist_question_list.dart';

/// One area's questions. On desktop the list of areas stays on the left, so
/// people can move between areas without going back.
class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key, required this.areaId});

  final String areaId;

  static const _areaPaneWidth = 320.0;

  @override
  Widget build(BuildContext context) {
    final area = AssessmentArea.byId(areaId);
    final isDesktop = Breakpoints.isDesktop(context);

    return PageScaffold(
      title: area?.name ?? AppStrings.assessmentAreas,
      description: PageText.assess,
      // The area list is already visible on the left, so no back button.
      showBack: false,
      primaryAction: area == null
          ? null
          : FilledButton.icon(
              onPressed: () => context.go(AppRoutes.photoCheck(area.id)),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text(AppStrings.checkPhotoOfArea),
            ),
      body: area == null
          ? const Center(child: Text(AppStrings.areaNotFound))
          : DataGate(
              builder: (context) => isDesktop
                  ? _buildSplitView(context, area)
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: ChecklistQuestionList(area: area),
                      ),
                    ),
            ),
    );
  }

  Widget _buildSplitView(BuildContext context, AssessmentArea area) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: _areaPaneWidth,
          child: AreaListPane(
            selectedAreaId: area.id,
            onSelected: (selected) =>
                context.go(AppRoutes.checklist(selected.id)),
          ),
        ),
        const SizedBox(width: Space.md),
        Expanded(
          child: ChecklistQuestionList(
            area: area,
            showPhotoButton: false,
            padding: const EdgeInsets.fromLTRB(0, 0, Space.md, Space.lg),
          ),
        ),
      ],
    );
  }
}
