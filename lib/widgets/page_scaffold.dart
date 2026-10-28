import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout.dart';
import 'page_header.dart';

/// Every signed-in page uses this. Phones and small tablets keep the normal
/// app bar; desktop gets a [PageHeader] above content centred at 1200 px.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.description,
    this.primaryAction,
    this.appBarActions,
    this.showBack = true,
  });

  final String title;
  final Widget body;

  /// Desktop only: one line under the title.
  final String? description;

  /// Desktop only: the page's main button, shown on the right of the header.
  final Widget? primaryAction;

  /// Phone only: icons in the app bar. On desktop the sidebar covers them.
  final List<Widget>? appBarActions;

  /// Desktop only: false hides the back button, e.g. in a split view where
  /// the previous page is already visible.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.isDesktop(context)) {
      return Scaffold(
        appBar: AppBar(title: Text(title), actions: appBarActions),
        body: body,
      );
    }

    final canGoBack = showBack && GoRouter.of(context).canPop();
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Space.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: title,
                description: description,
                primaryAction: primaryAction,
                onBack: canGoBack ? () => context.pop() : null,
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
