class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App info
  static const String appName = 'SplitPlan';
  static const String appVersion = '1.0.0';

  // Error messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String loading = 'Loading...';
  static const String error = 'Error';

  // Validation messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String nameRequired = 'Name is required';
  static const String amountRequired = 'Amount is required';
  static const String amountInvalid = 'Please enter a valid amount';
  static const String descriptionRequired = 'Description is required';
  static const String groupNameRequired = 'Group name is required';

  // Success messages
  static const String loginSuccess = 'Logged in successfully';
  static const String signupSuccess = 'Account created successfully';
  static const String groupCreated = 'Group created successfully';
  static const String expenseAdded = 'Expense added successfully';
  static const String settlementRecorded = 'Settlement recorded successfully';

  // Empty state messages
  static const String noGroups =
      'No groups yet.\nCreate your first group to get started!';
  static const String noExpenses =
      'No expenses yet.\nAdd an expense to start tracking!';
  static const String noMembers = 'No members in this group';
  static const String noSettlements = 'No settlements yet';

  // Button labels
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String createAccount = 'Create Account';
  static const String createGroup = 'Create Group';
  static const String addExpense = 'Add Expense';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String markAsSettled = 'Mark as Settled';
  static const String addMember = 'Add Member';
  static const String removeMember = 'Remove Member';

  // Screen titles
  static const String home = 'Home';
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String profile = 'Profile';
  static const String groupDetails = 'Group Details';
  static const String expenseDetails = 'Expense Details';
  static const String settings = 'Settings';

  // Tab labels
  static const String expenses = 'Expenses';
  static const String balances = 'Balances';
  static const String members = 'Members';

  // Split types
  static const String splitEqually = 'Split Equally';
  static const String splitCustom = 'Custom Split';
}
