import 'package:flutter/material.dart';

import '../../strings.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isWaiting,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isWaiting;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: AppStrings.askAQuestion,
              ),
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: isWaiting ? null : onSend,
            icon: const Icon(Icons.send),
            tooltip: AppStrings.send,
            iconSize: 28,
            padding: const EdgeInsets.all(14),
          ),
        ],
      ),
    );
  }
}
