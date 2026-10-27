import '../strings.dart';

/// An AI-written summary of the gap report. Shown on screen and copied, but
/// never saved.
class ReportSummary {
  const ReportSummary({
    required this.overview,
    required this.priorities,
    required this.nextSteps,
  });

  final String overview;
  final List<({String title, String reason})> priorities;
  final List<String> nextSteps;

  /// Plain text for pasting into an email or report. Keeps the AI label so it
  /// travels with the text.
  String toPlainText() {
    final buffer = StringBuffer()
      ..writeln(AppStrings.aiSummaryLabel)
      ..writeln()
      ..writeln(overview);
    if (priorities.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(AppStrings.topPriorities);
      for (final (index, priority) in priorities.indexed) {
        buffer.writeln('${index + 1}. ${priority.title}: ${priority.reason}');
      }
    }
    if (nextSteps.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(AppStrings.nextSteps);
      for (final step in nextSteps) {
        buffer.writeln('- $step');
      }
    }
    return buffer.toString().trimRight();
  }
}
