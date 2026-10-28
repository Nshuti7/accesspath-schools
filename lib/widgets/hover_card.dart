import 'package:flutter/material.dart';

/// A tappable card that lifts on mouse hover and gets a thick dark outline
/// when focused with the keyboard, so both are easy to see.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.onTap,
    required this.child,
    this.borderColor,
  });

  final VoidCallback onTap;
  final Widget child;

  /// A permanent outline, e.g. red for a warning. Focus still wins.
  final Color? borderColor;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final border = _focused
        ? BorderSide(color: colors.onSurface, width: 3)
        : widget.borderColor != null
        ? BorderSide(color: widget.borderColor!, width: 2)
        : _hovered
        ? BorderSide(color: colors.primary)
        : BorderSide.none;

    return AnimatedScale(
      scale: _hovered ? 1.02 : 1,
      duration: const Duration(milliseconds: 120),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: _hovered ? 4 : 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border,
        ),
        child: InkWell(
          onTap: widget.onTap,
          onHover: (value) => setState(() => _hovered = value),
          onFocusChange: (value) => setState(() => _focused = value),
          child: widget.child,
        ),
      ),
    );
  }
}
