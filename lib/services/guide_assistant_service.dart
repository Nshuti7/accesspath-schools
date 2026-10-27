import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/services.dart';

import '../models/chat_message.dart';
import 'ai_call.dart';

class GuideAssistantService {
  static const _knowledgePath = 'assets/data/guide_knowledge.md';

  /// Older turns are dropped so long chats stay inside the free-tier limits.
  static const _maxHistory = 12;

  static const _rules = '''
You are the AccessPath guide assistant. You help staff at schools in Uganda
understand the Ministry of Education and Sports (MOES) School Accessibility
Companion Guide. The guide's content is given below, after "GUIDE CONTENT".

Rules:
- Only answer questions about school accessibility. For anything else, say
  politely that you can only help with school accessibility and the guide.
- Use only the guide content below. Do not add standards, measurements or
  advice from anywhere else.
- Cite the printed page for every fact, like "(Guide p. 12)" or
  "(Guide pp. 12, 14)".
- If the guide does not cover something, say "The guide does not cover this"
  and, if it helps, suggest which part of the guide is closest.
- Keep answers short: a few sentences or a short list. Use plain English for
  school staff, not engineers. Explain terms such as "gradient" simply.
- Never say a school, building or facility is compliant, accessible,
  certified or approved. You can explain what the guide asks for; checking
  the building is for the school's assessment team.
- When the guide marks something as a "MOES recommendation", say it is a
  recommendation.
- Write plain text with no Markdown symbols such as ** or #. For a list, start
  each line with "- ".

GUIDE CONTENT
''';

  String? _systemInstruction;

  Future<String> _loadSystemInstruction() async {
    return _systemInstruction ??=
        _rules + await rootBundle.loadString(_knowledgePath);
  }

  /// Sends the chat so far (ending with the user's new question) and returns
  /// the assistant's answer. Throws [AiException] with a friendly reason.
  Future<String> ask(List<ChatMessage> history) async {
    final model = FirebaseAI.googleAI().generativeModel(
      model: geminiModelName,
      systemInstruction: Content.system(await _loadSystemInstruction()),
    );
    final recent = history.length > _maxHistory
        ? history.sublist(history.length - _maxHistory)
        : history;
    final contents = [
      for (final message in recent)
        message.fromUser
            ? Content.text(message.text)
            : Content.model([TextPart(message.text)]),
    ];
    final answer = await runAiCall(() => model.generateContent(contents));
    return answer.trim();
  }
}
