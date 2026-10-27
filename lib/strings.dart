/// UI text used in more than one place, kept together so wording stays consistent.
class AppStrings {
  static const appName = 'AccessPath Schools';

  static const email = 'Email';
  static const password = 'Password';
  static const yourName = 'Your name';
  static const schoolName = 'School name';
  static const district = 'District';
  static const otherDistrict = 'Other';
  static const districtName = 'District name';
  static const schoolType = 'School type';
  static const schoolProfile = 'School profile';
  static const saveChanges = 'Save changes';
  static const schoolSaved = 'School details saved';
  static String schoolTypeLabel(String type) => switch (type) {
    'primary' => 'Primary',
    'secondary' => 'Secondary',
    'both' => 'Primary and secondary',
    _ => '',
  };

  static const logIn = 'Log in';
  static const signUp = 'Sign up';
  static const logOut = 'Log out';
  static const noAccount = 'New here? Create an account';
  static const haveAccount = 'Already have an account? Log in';

  static const navDashboard = 'Dashboard';
  static const navAssess = 'Assess';
  static const navGaps = 'Gaps';
  static const navActions = 'Actions';
  static const navGuide = 'Guide';
  static String greeting(DateTime now, String name) {
    final part = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    return name.isEmpty ? part : '$part, $name';
  }

  static const accessibilityScore = 'Accessibility score';
  static const scoreExplainer =
      'Questions answered Yes, out of those answered.';
  static const selfCheckNote = 'This is a self-check, not a certification.';
  static String scoreSemantics(int percent) =>
      'Accessibility score $percent percent';
  static String questionsAnswered(int answered, int total) =>
      '$answered of $total questions answered';
  static const openGaps = 'Open gaps';
  static const overdueActions = 'Overdue actions';
  static const progressByArea = 'Progress by area';
  static const nextSteps = 'Next steps';
  static const nextStepsIntro = 'High-priority gaps that nobody is fixing yet.';
  static const nextStepsNone =
      'Every high-priority gap has someone working on it. Well done.';
  static const startFirstAssessment = 'Start your first assessment';
  static const startFirstAssessmentBody =
      'Answer the checklist questions area by area. Your score, gaps and '
      'next steps will appear here.';
  static const assessmentAreas = 'Assessment areas';
  static const yes = 'Yes';
  static const no = 'No';
  static const unsure = 'Unsure';
  static const whyThisMatters = 'Why this matters';
  static const guidePage = 'Guide p.';
  static const moesRecommendation = 'MOES recommendation';
  static const guideAssistant = 'Guide assistant';
  static const guideIntro =
      'Ask how to make your school accessible. '
      'Answers come from the Ministry guide.';
  static const guideSourceNote =
      'From the MOES School Accessibility Companion Guide (2024)';
  static const guideStarterTitle = 'Try asking';
  static const guideStarterQuestions = [
    'How steep can a ramp be?',
    'What does an accessible toilet need?',
    'How wide should classroom doors be?',
    'How do we start an accessibility assessment?',
  ];
  static const askAQuestion = 'Ask a question';
  static const send = 'Send';
  static const lookingInGuide = 'Looking in the guide...';

  static const photoCheck = 'Photo check';
  static const checkPhotoOfArea = 'Check a photo of this area';
  static const takePhoto = 'Take photo';
  static const choosePhoto = 'Choose photo';
  static const photoCheckIntro =
      'Take a clear photo of the place you are checking. '
      'Gemini will look for possible barriers. A person must always confirm them.';
  static const photoNotStored =
      'Your photo is only sent for checking. It is not saved.';
  static const checkingPhoto = 'Checking photo...';
  static const possibleIssue = 'Possible issue – needs verification';
  static const linkedQuestion = 'Checklist question';
  static const accept = 'Accept';
  static const dismiss = 'Dismiss';
  static const addedToGaps = 'Added to the gap report';
  static const noBarriersSpotted =
      'No obvious barriers spotted. Still check each question yourself.';
  static const allFindingsReviewed = 'All findings reviewed.';
  static String confidence(String level) => 'Confidence: $level';
  static const gapReport = 'Gap report';
  static const noGapsYet =
      'No gaps yet. Answer checklist questions or run a photo check to find them.';
  static const statusOpen = 'Open';
  static const statusNeedsVerification = 'Needs verification';
  static const statusVerified = 'Verified';
  static const statusResolved = 'Resolved';
  static const sourceChecklist = 'Checklist';
  static const sourceAiPhoto = 'AI photo';
  static const photoCheckSaw = 'Photo check saw';
  static const assign = 'Assign';
  static const whatToDo = 'What to do';
  static const highPriority = 'High priority';
  static const mediumPriority = 'Medium priority';
  static const lowPriority = 'Low priority';
  static String resolvedGaps(int count) => 'Resolved gaps ($count)';
  static const actionTracker = 'Action tracker';
  static const assignAction = 'Assign action';
  static const actionTitle = 'Action';
  static const ownerName = 'Who will do it';
  static const ownerHint = 'e.g. Facilities manager';
  static const dueDate = 'Due date';
  static const chooseDate = 'Choose a date';
  static const notesOptional = 'Notes (optional)';
  static const saveAction = 'Save action';
  static const actionSaved = 'Action saved';
  static const gapNotFound = 'This gap could not be found';
  static const filterAll = 'All';
  static const statusTodo = 'To do';
  static const statusInProgress = 'In progress';
  static const statusDone = 'Done';
  static const changeStatus = 'Change status';
  static const noActionsYet =
      'No actions yet. Open the gap report and assign a gap to someone.';
  static const noActionsForFilter = 'No actions with this status.';
  static const markGapResolvedQuestion = 'Mark the gap as resolved too?';
  static const yesResolve = 'Yes, resolve';
  static const notNow = 'Not now';
  static const gapMarkedResolved = 'Gap marked as resolved';
  static String due(DateTime date) => 'Due ${formatDate(date)}';
  static String overdue(DateTime date) =>
      'Overdue, was due ${formatDate(date)}';
  static String assignedTo(String owner, DateTime date) =>
      'Assigned to $owner · due ${formatDate(date)}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Day-month-year with a written month, e.g. "3 Nov 2026", so it cannot be
  /// misread the way 03/11/2026 can.
  static String formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  static const tryAgain = 'Try again';
  static const areaNotFound = 'This area could not be found';
  static String answeredOf(int answered, int total) =>
      '$answered of $total answered';

  static const requiredField = 'Please fill this in';
  static const errorInvalidEmail = 'Please enter a valid email address';
  static const errorWrongLogin = 'Email or password is not correct';
  static const errorEmailInUse = 'An account with this email already exists';
  static const errorWeakPassword = 'Password must be at least 6 characters';
  static const errorAccountDisabled = 'This account has been turned off';
  static const errorOffline = 'No internet connection. Please try again';
  static const errorTooManyTries = 'Too many tries. Please wait and try again';
  static const errorGeneric = 'Something went wrong. Please try again';
  static const errorLoadAssessment =
      'Could not load the checklist. Check your connection and try again';
  static const errorSaveAnswer = 'Answer not saved. Please try again';
  static const errorSaveGap =
      'Could not add this to the gap report. Please try again';
  static const errorChooseDistrict = 'Please choose a district';
  static const errorChooseSchoolType = 'Please choose a school type';
  static const errorSaveSchool = 'School details not saved. Please try again';
  static const errorLoadSchool =
      'Could not load your school. Check your connection and try again';
  static const errorLoadActions =
      'Could not load actions. Check your connection and try again';
  static const errorSaveAction = 'Action not saved. Please try again';
  static const errorUpdateAction = 'Status not saved. Please try again';
  static const errorUpdateGap = 'Gap not updated. Please try again';
  static const errorChooseDate = 'Please choose a due date';
  static const errorCamera = 'Could not open the camera or photos';
  static const errorPhotoQuota =
      'The free photo check limit has been reached for now. '
      'Please try again later, or answer the questions yourself.';
  static const errorPhotoUnreadable =
      'We could not read the result for this photo. Please try again.';
  static const errorAiQuota =
      'The free AI limit has been reached for now. Please try again later.';
  static const errorAiUnreadable =
      'We could not read the answer. Please try again.';
  static const errorGuideUnavailable =
      'The guide assistant is not available right now. '
      'Please try again later.';
  static const errorPhotoUnavailable =
      'Photo check is not available right now. '
      'Please answer the questions yourself.';
}
