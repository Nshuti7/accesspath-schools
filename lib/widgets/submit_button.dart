import 'package:flutter/material.dart';

/// Full-width button that swaps its label for a spinner while [isBusy],
/// so users cannot submit the same form twice.
class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.label,
    required this.isBusy,
    required this.onPressed,
  });

  final String label;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isBusy ? null : onPressed,
      child: isBusy
          ? SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                semanticsLabel: label,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Text(label),
    );
  }
}
