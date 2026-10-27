import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../strings.dart';

/// User messages sit on the right; answers sit on the left with the source
/// note under them, so every answer is clearly tied to the guide.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final fromUser = message.fromUser;

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: fromUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: fromUser
                    ? colors.primaryContainer
                    : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              // Selectable so staff can copy an answer into a report.
              child: SelectableText(
                message.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: fromUser
                      ? colors.onPrimaryContainer
                      : colors.onSurface,
                ),
              ),
            ),
            if (!fromUser)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  AppStrings.guideSourceNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
