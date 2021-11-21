class AppStrings {

    // declaring app strings

  static AppStrings _instance = AppStrings._init();
  static AppStrings get instance => _instance;
  AppStrings._init();

///////////////////////////////////////////////////
///
  String levelChoose = 'Choose a level';
  String level1 = 'Beginner';
  String level2 = 'Easy';
  String level3 = 'Medium';
  String level4 = 'Difficult';
  String level5 = 'Hard';
  String level6 = 'Expert';

  String congratulation = 'Congratulations, sudoku has been successfuly solved!';
  String errorSudoku = 'You have mistakes in your Sudoku please check carefully!';

  String sudokuGame = 'Sudoku Game';

  String hint='Hint';
  String note='Note';
  String takeBack='Take Back';
  String pushForward='Push Forward';

  String level='Game Level';
  String duration='Duration';
  String playerName='Player Name';
  String remainingHint='Remaining Hint';
  String score='Score';

///
///can be used for language inputs
  String errorCYI = 'Check your information';
  String sudokuContestApp = "Sudoku Contest";
 
  //welcome.dart
  String welcomeTitle = "Welcome to Sudoku Contest";
  String email = 'email';
  String enterEmail = 'Please enter an email';
  String enterValidEmail = 'Please enter an valid email';
  String password = 'password';
  String enterPassword = 'Please enter a password';
  String confirmPassword = 'confirm password';
  String confirmPasswordMatch = 'Password is not matching';
  String name = 'name';
  String enterName = 'Please enter a name';
  String login = 'Login';
  String register = 'Register';

  //dashboard.dart
  String dashboard='Dashboard';

  String local = 'Local';
  String yearly = 'Yearly';
  String daily = 'Daily';
  String monthly = 'Monthly';
  String results = " Results";
  String gameDate="Sudoku Game Date: ";
  String gameDuration="Sudoku Solving Duration: ";

  String sudokuReplay="Sudoku Replay";

  //profile.dart
  String profilePicUpload = 'Profile Picture Uploaded';
  String profile = 'Profile';
  String signOut = 'Sign Out';
  String profileUpdated = 'Profile Updated';
  String update = 'Update';
  String cancel = 'Cancel';
  String uploadPicture = 'Upload Picture';
  String darkModeSwitch='Dark Mode';
  String languageSwitch='Turkish';

  //dataInput.dart

  String add = 'Add';
  String clearScreen = 'Clear Screen';
 
  //operation.dart

//balance.dart

  String clearFilters = 'Clear Filters';
  String filtersCleared = 'All filters cleared';


//income.dart

  String deleteConfirmation = 'Are you sure you want to delete';
  String delete = 'Delete';
 
  String edit = 'Edit';

}
