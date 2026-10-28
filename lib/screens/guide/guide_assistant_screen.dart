import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../page_text.dart';
import '../../providers/guide_chat_provider.dart';
import '../../services/ai_call.dart';
import '../../strings.dart';
import '../../widgets/form_error_text.dart';
import '../../widgets/page_scaffold.dart';
import 'chat_bubble.dart';
import 'chat_input_bar.dart';
import 'starter_questions.dart';

class GuideAssistantScreen extends StatefulWidget {
  const GuideAssistantScreen({super.key});

  @override
  State<GuideAssistantScreen> createState() => _GuideAssistantScreenState();
}

class _GuideAssistantScreenState extends State<GuideAssistantScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    final chat = context.read<GuideChatProvider>();
    _inputController.clear();
    _scrollToEnd();
    await chat.send(text);
    if (!mounted) return;
    // Put a failed question back so it can be sent again with one tap.
    final failed = chat.takeFailedQuestion();
    if (failed != null) _inputController.text = failed;
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  static String _messageFor(AiError error) {
    return switch (error) {
      AiError.offline => AppStrings.errorOffline,
      AiError.quotaReached => AppStrings.errorAiQuota,
      AiError.unreadableResponse => AppStrings.errorAiUnreadable,
      AiError.unavailable => AppStrings.errorGuideUnavailable,
    };
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<GuideChatProvider>();
    final messages = chat.messages;
    final error = chat.error;

    return PageScaffold(
      title: AppStrings.guideAssistant,
      description: PageText.guide,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                if (messages.isEmpty && !chat.isWaiting)
                  StarterQuestions(onSelected: _send),
                for (final message in messages)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ChatBubble(message: message),
                  ),
                if (chat.isWaiting)
                  const Row(
                    children: [
                      SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(AppStrings.lookingInGuide),
                    ],
                  ),
                if (error != null) FormErrorText(_messageFor(error)),
              ],
            ),
          ),
          ChatInputBar(
            controller: _inputController,
            isWaiting: chat.isWaiting,
            onSend: () => _send(_inputController.text),
          ),
        ],
      ),
    );
  }
}
