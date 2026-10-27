import 'package:accesspath_schools/models/chat_message.dart';
import 'package:accesspath_schools/providers/guide_chat_provider.dart';
import 'package:accesspath_schools/services/ai_call.dart';
import 'package:accesspath_schools/services/guide_assistant_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeService extends GuideAssistantService {
  _FakeService(this.reply);

  final Future<String> Function(List<ChatMessage> history) reply;

  @override
  Future<String> ask(List<ChatMessage> history) => reply(history);
}

void main() {
  test('a question and its answer are added to the chat', () async {
    final chat = GuideChatProvider(
      service: _FakeService((_) async => 'Not steeper than 1:12 (Guide p. 12)'),
    )..setUser('u1');

    await chat.send('How steep can a ramp be?');

    expect(chat.messages, hasLength(2));
    expect(chat.messages.first.fromUser, isTrue);
    expect(chat.messages.last.text, contains('Guide p. 12'));
    expect(chat.error, isNull);
  });

  test('a failed question is removed and offered back', () async {
    final chat = GuideChatProvider(
      service: _FakeService(
        (_) async => throw const AiException(AiError.quotaReached),
      ),
    )..setUser('u1');

    await chat.send('How wide should doors be?');

    expect(chat.messages, isEmpty);
    expect(chat.error, AiError.quotaReached);
    expect(chat.takeFailedQuestion(), 'How wide should doors be?');
    expect(chat.takeFailedQuestion(), isNull);
  });

  test('changing user clears the chat', () async {
    final chat = GuideChatProvider(service: _FakeService((_) async => 'Hi'))
      ..setUser('u1');
    await chat.send('Hello');

    chat.setUser('u2');

    expect(chat.messages, isEmpty);
  });
}
