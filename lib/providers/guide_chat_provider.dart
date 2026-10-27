import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../services/ai_call.dart';
import '../services/guide_assistant_service.dart';

/// Holds the guide assistant chat while the app is open. Nothing is saved, and
/// the chat is cleared when the user changes.
class GuideChatProvider extends ChangeNotifier {
  GuideChatProvider({GuideAssistantService? service})
    : _service = service ?? GuideAssistantService();

  final GuideAssistantService _service;

  String? _uid;
  List<ChatMessage> _messages = const [];
  bool _isWaiting = false;
  AiError? _error;
  String? _failedQuestion;

  List<ChatMessage> get messages => _messages;
  bool get isWaiting => _isWaiting;
  AiError? get error => _error;

  void setUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _messages = const [];
    _isWaiting = false;
    _error = null;
    _failedQuestion = null;
  }

  Future<void> send(String text) async {
    final question = text.trim();
    if (question.isEmpty || _isWaiting) return;

    final uid = _uid;
    _messages = [..._messages, ChatMessage(text: question, fromUser: true)];
    _isWaiting = true;
    _error = null;
    notifyListeners();

    try {
      final answer = await _service.ask(_messages);
      // Someone else logged in while we waited; their chat starts empty.
      if (uid != _uid) return;
      _messages = [..._messages, ChatMessage(text: answer, fromUser: false)];
    } on AiException catch (error) {
      if (uid != _uid) return;
      // Drop the unanswered question so the next request does not send two
      // user turns in a row; the screen offers it again with the error.
      _messages = _messages.sublist(0, _messages.length - 1);
      _error = error.reason;
      _failedQuestion = question;
    } finally {
      if (uid == _uid) {
        _isWaiting = false;
        notifyListeners();
      }
    }
  }

  /// The question that just failed, so the input box can offer it again.
  String? takeFailedQuestion() {
    final question = _failedQuestion;
    _failedQuestion = null;
    return question;
  }
}
