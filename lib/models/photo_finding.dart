/// One possible barrier Gemini spotted in a photo. Never treated as a
/// confirmed gap until a person accepts it.
class PhotoFinding {
  const PhotoFinding({
    required this.itemId,
    required this.finding,
    required this.confidence,
  });

  final String itemId;
  final String finding;

  /// 'low', 'medium' or 'high'.
  final String confidence;
}
