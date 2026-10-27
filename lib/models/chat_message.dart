/// One message in the guide assistant chat. Kept in memory only.
class ChatMessage {
  const ChatMessage({required this.text, required this.fromUser});

  final String text;
  final bool fromUser;
}
