import 'package:ai_gen/core/data/cache/cahch_keys.dart';
import 'package:flutter/material.dart';

abstract class TranslationKeys {
  static const Locale localeEN = Locale(CacheKeys.keyEN);
  static const Locale localeAR = Locale(CacheKeys.keyAR);
  static const String chooseProducts = 'ChooseProducts';
  static const String makePayment = 'Make Payment';
  static const String getYourOrder = 'Get Your Order';
  static const String body =
      'Alot of talk, Alot of talk, Alot of talk, Alot of talk, Alot of talk, Alot of talk, Alot of talk, Alot of talk';
  static const String prev = 'Prev';
  static const String next = 'Next';
  static const String save = 'Save';
  static const String arabic = 'AR';
  static const String english = 'EN';
  static const String language = 'Language';
  static const String settings = 'Settings';
  static const String settingsDescription = 'Manage your account settings';

  static const String profile = 'Profile';
  static const String search = 'Search';
  static const String searchAnyProduct = 'Search any Product..';
  static const String Items = 'Items';

  static const String userFullName = 'User full Name';
  static const String myProfile = 'My Profile';
  static const String myOrders = 'My Orders';
  static const String myFavorites = 'My Favorites';
  static const String logOut = 'Log Out';

  static const String skip = 'Skip';
  static const String getStarted = 'Get Started';
  static const String createAccount = 'Create Account';
  static const String login = 'Login';
  static const String register = 'Register';

  static const String emailHintText = 'Email';
  static const String passwordHintText = 'Password';
  static const String confirmPasswordHintText = 'Confirm Password';
  static const String phoneHintText = 'Phone';
  static const String fullNameHintText = 'Full Name';

  static const String findItHereHuyItNow = 'Find it here, buy it now!';
  static const String youWantAuthenticHereYouGo =
      'You want Authentic, here you go!';
  static const String welcomeBack = 'Welcome \nBack!';
  static const String createAnAccount = 'Create an\n account';
  static const String account = 'Account';
  static const String appearance = 'Appearance';

  static const String fullNameIsRequired = 'Full name is required';
  static const String passwordIsRequired = 'Password is required';
  static const String shortPassword = "Password must be at least 6 characters";
  static const String confirmPasswordIsRequired =
      'Confirm Password is required';
  static const String confirmShortPassword =
      "Confirm Password must be at least 6 characters";

  static const String emailIsRequired = 'Email is required';
  static const String emailNotValid = 'Email is not valid';
  static const String passwordNotValid = 'Password is not valid';
  static const String passwordNotMatch = 'Password not match';
  static const String phoneIsRequired = 'Phone is required';
  static const String phoneNotValid = 'Phone is not valid';
  static const String checkAllFieldsMsg = 'Please fill all fields';

  static const String home = 'Home';
  static const String items = 'Items';
  static const String addToCart = 'Add To Cart';
  static const String MyFavorites = 'My Favorites';
  static const String NoFavouritesYet = 'No Favourites Yet';

  static const String SearchanyProduct = 'Search any Product..';
  static const String AllFeatured = 'All Featured';
  static const String Recommended = 'Recommended';
  static const String AndMore = 'And More !!';
  static const String AddToCart = 'Add To Cart';
  static const String Search = 'Search';
  static const String NoResultsFound = 'No Results Found';
  static const String ProductAddedToCart = 'Product Added To Cart Successfully';

  // New keys for server status
  static const String loadingServer = 'Loading Server....';
  static const String checkingServerStatus = 'Checking server status...';
  static const String startingBackendServer = 'Starting backend server...';
  static const String serverStoppedUnexpectedly =
      'Server process stopped unexpectedly.';
  static const String waitingForServerToStart =
      'Waiting for server to start...'; // Placeholder for dynamic part
  static const String errorStartingServer =
      'Error starting server:'; // Placeholder for dynamic part
  static const String serverRunningLoadingDashboard =
      'Server is running. Loading dashboard...';
  static const String failedToStartServer =
      'Failed to start server. Please check if the backend is properly configured.';

  // New keys for login/welcome
  static const String welcomeBackToModelCraft = 'Welcome Back to\nModel Craft!';
  static const String signInToContinueDesigning =
      'Sign in to continue designing and refining your models.';
  static const String signInToContinue = 'Sign in to continue';
  static const String loginSuccessful = 'Login Successful!';
  static const String redirectingToDashboard = 'Redirecting to dashboard...';
  static const String signIn = 'Sign In';
  static const String emailAddress = 'Email address';
  static const String rememberMe = 'Remember me';
  static const String forgotPassword = 'Forgot password?';
  static const String orSignInWith = 'Or sign in with';
  static const String dontHaveAnAccount = 'Don\'t have an account?';
  static const String createFreeAccount = 'Create free account';

  // New keys for signup
  static const String joinModelCraftToday = 'Join Model Craft\nToday';
  static const String createAccountAndStartBringing =
      'Create an account and start bringing your models to life.';
  static const String signUp = 'Sign Up';
  static const String username = 'Username';
  static const String firstName = 'First name';
  static const String lastName = 'Last name';
  static const String confirmPassword =
      'Confirm Password'; // Re-using existing if possible, otherwise new
  static const String iAgreeWithThe = 'I agree with the ';
  static const String termsAndConditions = 'Terms & Conditions';
  static const String ofClarity = ' of Clarity';
  static const String buttonSignUp = 'Sign up';

  static const String retry = 'Retry';

  // New keys for Datasets Screen
  static const String datasets = 'Datasets';
  static const String datasetsDescription =
      'Discover and use high-quality datasets for training and\n fine-tuning machine learning models.';
  static const String filter = 'Filter';
  static const String yourDatasets = 'Your Datasets';
  static const String seeAll = 'See all';
  static const String error = 'Error:';

  static const String noResultsFoundFor = 'No results found for: ';
  static const String noDatasetsAvailable = 'No datasets available';
  static const String projectsCount =
      ' Projects • '; // Part of "X Projects • Y Models"
  static const String modelsCount =
      ' Models'; // Part of "X Projects • Y Models"
  static const String datasetCollection = 'Dataset Collection';
  static const String comprehensiveDatasetDescription =
      'A comprehensive dataset for training and evaluation';
  static const String guest = 'Guest';

  // New keys for Project Item
  static const String unnamedProject = 'Unnamed Project';
  static const String created = 'Created: '; // Part of "Created: Date"
  // New keys for Models Screen
  static const String models = 'Models';
  static const String modelsDescription =
      'Discover and use high-quality models for various machine learning tasks.';
  static const String yourModels = 'Your Models';
  static const String noModelsFound = 'No models found ';
  static const String noModelAvailable = 'No models available';
  static const String addModelsFromStore =
      'No models found /n You can add models from the AI Model Store.';
  static const String variation =
      ' Variation • '; // Part of "X Variation • Y Projects"
  static const String modelDescriptionPrefix = 'description: ';
  static const String defaultModelDescription =
      'A collection of AI models for various tasks';
  static const String projectsCountModels = ' Projects';

  // New keys for Playlist Screen
  static const String learn = 'Learn';
  static const String learnDescription =
      'Gain the skills you need to create your model.';
  static const String noTitle = 'No Title';
  static const String noDescription = 'No Description';
  static const String na = 'N/A'; // Not Applicable for duration
  static const String basicsCategory = 'Basics';
  static const String datasetCategory = 'Dataset';
  static const String watchLater = 'Watch Later';
  static const String share = 'Share';
  static const String noVideosFound = 'No videos found.';
  static const String noVideosMatchSearch = 'No videos match your search.';
  static const String playlistApiError = 'Playlist API Error: ';
  static const String responseBody = 'Response body: ';
  static const String failedToLoadPlaylistVideos =
      'Failed to load playlist videos: ';
  static const String noItemsFoundInPlaylist = 'No items found in playlist';
  static const String noValidVideoIdsFound = 'No valid video IDs found';
  static const String videoDetailsApiError = 'Video details API Error: ';
  static const String errorFetchingPlaylist = 'Error fetching playlist: ';
  // New keys for Sidebar
  static const String collapse = 'Collapse';
  static const String explore = 'Explore';
  static const String docs = 'Docs';

  // New keys for Profile Screen
  static const String logout = 'Logout';
  static const String sessionExpiredMessage =
      'Your session has expired. You need to log in again.';
  static const String cancel = 'Cancel';
  static const String loginAgain = 'Login Again';
  static const String sessionExpired = 'Session Expired';
  static const String errorLoadingProfile = 'Error Loading Profile';
  static const String tryAgain = 'Try Again';
  static const String goToDashboard = 'Go to Dashboard';
  static const String profileScreenTitle =
      'Profile'; // Distinct from general 'profile'
  static const String loadingProfile = 'Loading profile...';
  static const String nameLabel = 'Name:';

  static const String usernameLabel = 'Username:';
  static const String emailAddressLabel = 'Email Address:';
  static const String bioLabel = 'Bio:';
  static const String writeAboutYourself = 'Write about yourself';
  static const String saveChanges = 'Save changes';
  static const String loadProfile = 'Load Profile';
  static const String refresh =
      'Refresh'; // For refresh button tooltip or accessibility

  // New keys for Projects Table
  static const String noProjectsFoundTable =
      'No Projects Found'; // Specific to table
  static const String deletingEmptyProjects = 'Deleting empty projects...';
  static const String deletingProject = 'Deleting project...';
  static const String projectDeletedSuccessfully =
      'project deleted successfully'; // Singular
  static const String projectsDeletedSuccessfully =
      'projects deleted successfully'; // Plural
  static const String failedToDeleteProjects =
      'Failed to delete projects: '; // Append status code
  static const String errorDeletingProjects =
      'Error deleting projects: '; // Append error message
  static const String emptyProjectsDeletedSuccessfully =
      'Empty projects deleted successfully';
  static const String failedToDeleteEmptyProjects =
      'Failed to delete empty projects: '; // Append status code
  static const String errorDeletingEmptyProjects =
      'Error deleting empty projects: '; // Append error message

  // Inferred dialog/table header/list item strings
  static const String confirmDeletion = 'Confirm Deletion';
  static const String deleteConfirmationMessage =
      'Are you sure you want to delete the selected project(s)? This action cannot be undone.';
  static const String deleteEmptyProjectsConfirmationMessage =
      'Are you sure you want to delete all empty projects? This action cannot be undone.';
  static const String deleteButton = 'Delete';
  static const String allProjects = 'All';
  static const String selectedProjects = 'Selected';
  static const String deleteSelected = 'Delete Selected';
  static const String deleteEmptyProjects = 'Delete Empty Projects';
  static const String projectNameHeader = 'Name';
  static const String createdAtHeader = 'Created At';
  static const String lastModifiedHeader = 'Last Modified';
  static const String actionsHeader = 'Actions';
  static const String openProject = 'Open Project';
  static const String editProject = 'Edit';
  static const String previousPage = 'Previous';
  static const String nextPage = 'Next';
  static const String trySearchingWithDifferentKeywords =
      'Try searching with different keywords';
  static const String showAllProjects = 'Show All Projects';
  static const String newPasswordAndConfirmationMustMatch =
      "New password and confirmation must match";
  static const String passwordChangedSuccessfully =
      "Password changed successfully";
  static const String currentPasswordTitle = "Current Password:";
  static const String changePasswordTitle = "Change Password:";
  static const String confirmPasswordTitle = "Confirm Password:";
  static const String confirm = "Confirm";
  static const String prefrenceModeTitle = 'Preference mode';
  static const String lightMode = 'Light mode';
  static const String darkMode = 'Dark mode';
  static const String selectAllProjects = "Select all projects";
  static const String deselectAllProjects = "Deselect all projects";
  static const String deleteSelectedProjects = "Delete selected projects";
  static const String deleteAllEmptyProjects =
      "Delete all empty projects (projects with no model or dataset)";
  static const String name = 'Name';
  static const String description = "Description";
  static const String dataset = "Dataset";
  static const String model = "Model";
  static const String createdAt = "Created At";
  static const String undoSelectionTitle =
      "Click to select/deselect this project for deletion";
  static const String doYouWantToDelete = "Do you want to delete this project?";

  static const String projectName = "Project Name";
  static const String noDescriptionTitle = "No description";
  static const String noDataset = "No Dataset";
  static const String noModel = "No Model";
  static const String previous = "Previous";
  static const String projects = "Projects";
  static const String project = "Project";
  static const String viewAllProjects = 'View all your projects';
  static const String import = "Import";
  static const String questionMark = "?";
  static const String export = "Export";
  static const String newProject = "New Project";
  static const String searchHint = "Find a project";

  static const String projectsToBeDeleted = 'Projects to be deleted:';
  static const String areYouSure = "Are you sure you want to delete ";
  static const String thisActionCannotBeUndone =
      " This action cannot be undone.";
  static const String deleteEmpty = 'Delete Empty';
  static const String areYouSureYouWantToDeleteEmptyProjects =
      'Are you sure you want to delete all empty projects? This will remove all projects that have no model or dataset assigned. This action cannot be undone.';
  static const String thisTitle = 'this';
  static const String theseTitle = 'these';
  // في translation_keys.dart
  static const String advancedSearch = 'Advanced_Search';
  static const String advancedSearchDescription = 'advanced_search_description';
  static const String selectModel = 'select_model';
  static const String selectDataset = 'select_dataset';
  static const String clearFilters = 'clear_filters';
  static const String searchResults = 'search_results';
  static const String modelCopied = 'model_copied';
  static const String datasetCopied = 'dataset_copied';
  static const String copyToClipboard = 'copy_to_clipboard';
  static const String all = 'all';
  static const String noProjectsFound = 'no_projects_found';
  static const String searchProjectsModelsDatasetsHint =
      'search_projects_models_datasets_hint';
}
