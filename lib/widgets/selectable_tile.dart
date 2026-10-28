import 'package:flutter/material.dart';

/// A row in a desktop list (sidebar, area list). The selected row gets a
/// filled background, a bar on the left and bold text, never colour alone.
/// Hover tints the row; keyboard focus draws a thick dark outline.
class SelectableTile extends StatefulWidget {
  const SelectableTile({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.below,
    this.trailing,
    this.semanticsHint,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// Extra line under the label, e.g. a progress bar.
  final Widget? below;
  final Widget? trailing;
  final String? semanticsHint;

  @override
  State<SelectableTile> createState() => _SelectableTileState();
}

class _SelectableTileState extends State<SelectableTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = widget.isSelected;
    final foreground = selected ? colors.onPrimaryContainer : colors.onSurface;
    final below = widget.below;
    final trailing = widget.trailing;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        button: true,
        selected: selected,
        hint: widget.semanticsHint,
        child: Material(
          color: selected ? colors.primaryContainer : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: _focused
                ? BorderSide(color: colors.onSurface, width: 3)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onFocusChange: (value) => setState(() => _focused = value),
            hoverColor: colors.primary.withValues(alpha: 0.08),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: selected ? colors.primary : Colors.transparent,
                    width: 4,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: selected ? colors.primary : foreground,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: foreground,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        if (below != null) ...[
                          const SizedBox(height: 4),
                          below,
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 8), trailing],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
