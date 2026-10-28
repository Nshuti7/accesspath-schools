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

  static const _labels = {
    AnswerValue.yes: AppStrings.yes,
    AnswerValue.no: AppStrings.no,
    AnswerValue.unsure: AppStrings.unsure,
  };

  @override
  Widget build(BuildContext context) {
    final current = selected;

    return SegmentedButton<AnswerValue>(
      segments: [
        for (final MapEntry(key: value, value: text) in _labels.entries)
          ButtonSegment(
            value: value,
            label: _Label(text, isSelected: value == current),
          ),
      ],
      // Fill the card so each answer gets a third of the width.
      expandedInsets: EdgeInsets.zero,
      // The built-in tick sits outside the label and cannot shrink with it,
      // so on small phones it squeezed "Unsure" off the button. _Label draws
      // its own tick instead.
      showSelectedIcon: false,
      selected: current == null ? const {} : {current},
      // Allows the "nothing answered yet" state.
      emptySelectionAllowed: true,
      onSelectionChanged: (values) {
        // Tapping the current answer again would clear it; keep it instead.
        if (values.isNotEmpty) onChanged(values.first);
      },
      style: const ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(0, 52)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
      ),
    );
  }
}

/// One answer on a single line, with a tick when selected. Shrinks slightly
/// on very narrow screens rather than wrapping or cutting the word.
class _Label extends StatelessWidget {
  const _Label(this.text, {required this.isSelected});

  final String text;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            const Icon(Icons.check, size: 18),
            const SizedBox(width: 4),
          ],
          Text(text, maxLines: 1, softWrap: false),
        ],
      ),
    );
  }
}
