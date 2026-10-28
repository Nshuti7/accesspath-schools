/// Text used only by the desktop layout: page header descriptions and table
/// headings. Kept apart from AppStrings so that file stays readable.
class PageText {
  static const assess =
      'Answer each question for every area. Answers save as you go.';
  static const photoCheck =
      'Take a photo and see possible barriers to check yourself.';
  static const gaps =
      'Barriers found by the checklist and photo checks, by priority.';
  static const assignAction = 'Choose who will fix this gap and by when.';
  static const actions = 'Who is fixing each gap, and by when.';
  static const guide = 'Ask about the Ministry school accessibility guide.';
  static const schoolProfile = 'Your school name, district and type.';
  static const continueAssessment = 'Continue assessment';
  static const startAssessment = 'Start assessment';
  static const back = 'Back';
  static const mainNavigation = 'Main navigation';
  static const openSchoolProfile = 'Open school profile';

  static const columnPriority = 'Priority';
  static const columnQuestion = 'Question';
  static const columnArea = 'Area';
  static const columnSource = 'Source';
  static const columnStatus = 'Status';
  static const columnOwner = 'Owner';
  static const columnDueDate = 'Due date';
  static const notAssigned = 'Not assigned';
  static const notSet = 'Not set';
  static const overdue = 'Overdue';
  static const allGaps = 'All gaps';
  static const close = 'Close';
  static String priorityLabel(String priority) => switch (priority) {
    'high' => 'High',
    'medium' => 'Medium',
    _ => 'Low',
  };

  /// Sorts high before medium before low.
  static int priorityRank(String priority) => switch (priority) {
    'high' => 0,
    'medium' => 1,
    _ => 2,
  };
}
