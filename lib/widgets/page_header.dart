import 'package:flutter/material.dart';

import '../layout.dart';
import '../page_text.dart';

/// Desktop page header: title, one-line description and the page's main
/// action on the right. Sub-pages also get a back button.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.description,
    this.primaryAction,
    this.onBack,
  });

  final String title;
  final String? description;
  final Widget? primaryAction;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = this.description;
    final primaryAction = this.primaryAction;
    final onBack = this.onBack;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.md,
        Space.lg,
        Space.md,
        Space.md,
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              tooltip: PageText.back,
            ),
            const SizedBox(width: Space.xs),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: theme.textTheme.headlineMedium),
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: Space.xs),
                  Text(
                    description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (primaryAction != null) ...[
            const SizedBox(width: Space.md),
            primaryAction,
          ],
        ],
      ),
    );
  }
}
