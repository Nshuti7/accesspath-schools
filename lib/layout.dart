import 'package:flutter/widgets.dart';

/// Screen widths where the layout changes. Phones stay below [rail].
class Breakpoints {
  /// Side rail instead of the bottom bar (small tablets).
  static const rail = 800.0;

  /// Full sidebar, page headers, tables and split views.
  static const desktop = 1000.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}

/// Spacing on an 8 px scale, used by the desktop layouts.
class Space {
  static const xs = 8.0;
  static const sm = 16.0;
  static const md = 24.0;
  static const lg = 32.0;

  /// Desktop content is centred and never wider than this.
  static const maxContentWidth = 1200.0;
  static const sidebarWidth = 240.0;
}
