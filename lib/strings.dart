/// UI text used in more than one place, kept together so wording stays consistent.
class AppStrings {
  static const appName = 'AccessPath Schools';

  static const email = 'Email';
  static const password = 'Password';
  static const yourName = 'Your name';
  static const schoolName = 'School name';

  static const logIn = 'Log in';
  static const signUp = 'Sign up';
  static const logOut = 'Log out';
  static const noAccount = 'New here? Create an account';
  static const haveAccount = 'Already have an account? Log in';

  static const startAssessment = 'Start assessment';
  static const assessmentAreas = 'Assessment areas';
  static const yes = 'Yes';
  static const no = 'No';
  static const unsure = 'Unsure';
  static const whyThisMatters = 'Why this matters';
  static const guidePage = 'Guide p.';
  static const moesRecommendation = 'MOES recommendation';
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
  static const errorCamera = 'Could not open the camera or photos';
  static const errorPhotoQuota =
      'The free photo check limit has been reached for now. '
      'Please try again later, or answer the questions yourself.';
  static const errorPhotoUnreadable =
      'We could not read the result for this photo. Please try again.';
  static const errorPhotoUnavailable =
      'Photo check is not available right now. '
      'Please answer the questions yourself.';
}
