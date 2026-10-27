import 'answer.dart';
import 'gap.dart';

/// Totals shown on the Dashboard and Gap report, worked out in one place so
/// both screens always agree.
class AssessmentStats {
  const AssessmentStats({
    required this.totalItems,
    required this.answeredCount,
    required this.yesCount,
    required this.openGaps,
    required this.needsVerificationGaps,
    required this.resolvedGaps,
  });

  factory AssessmentStats.from({
    required int totalItems,
    required Iterable<Answer> answers,
    required Iterable<Gap> gaps,
  }) {
    var open = 0;
    var needsVerification = 0;
    var resolved = 0;
    for (final gap in gaps) {
      switch (gap.status) {
        case Gap.statusResolved:
          resolved++;
        case Gap.statusNeedsVerification:
          needsVerification++;
        // Verified gaps are confirmed barriers, so they count as open.
        default:
          open++;
      }
    }
    return AssessmentStats(
      totalItems: totalItems,
      answeredCount: answers.length,
      yesCount: answers
          .where((answer) => answer.value == AnswerValue.yes)
          .length,
      openGaps: open,
      needsVerificationGaps: needsVerification,
      resolvedGaps: resolved,
    );
  }

  final int totalItems;
  final int answeredCount;
  final int yesCount;
  final int openGaps;
  final int needsVerificationGaps;
  final int resolvedGaps;

  /// "Yes" answers as a share of answers given, 0 to 100. Null before any
  /// question is answered, because 0% would wrongly suggest a bad result.
  int? get scorePercent {
    if (answeredCount == 0) return null;
    return (yesCount * 100 / answeredCount).round();
  }
}
