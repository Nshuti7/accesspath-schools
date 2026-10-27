import 'package:flutter/material.dart';

import '../../models/answer.dart';
import '../../strings.dart';

/// Yes / No / Unsure choice. The selected option shows a tick as well as a
/// colour change, so it is clear to people who cannot tell colours apart.
class AnswerButtons extends StatelessWidget {
  const AnswerButtons({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AnswerValue? selected;
  final ValueChanged<AnswerValue> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = selected;

    return SegmentedButton<AnswerValue>(
      segments: const [
        ButtonSegment(value: AnswerValue.yes, label: Text(AppStrings.yes)),
        ButtonSegment(value: AnswerValue.no, label: Text(AppStrings.no)),
        ButtonSegment(
          value: AnswerValue.unsure,
          label: Text(AppStrings.unsure),
        ),
      ],
      selected: current == null ? const {} : {current},
      // Allows the "nothing answered yet" state.
      emptySelectionAllowed: true,
      onSelectionChanged: (values) {
        // Tapping the current answer again would clear it; keep it instead.
        if (values.isNotEmpty) onChanged(values.first);
      },
      style: const ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(0, 52)),
      ),
    );
  }
}
