abstract class NetworkConstants {
  static const String baseURL = "http://127.0.0.1:8000/api";
  static const String chatBaseURL = "http://127.0.0.1:8080";
  static const String allComponentsEndPoint = "components";
  static const String projectEndPoint = "projects";
  static const String nodesEndPoint = "nodes";
  static const String allComponentsApi = "components";
  static const String importProjectEndPoint = "import-project";
  static const String exportProjectEndPoint = "export-project";
  static const String apiAuthBaseUrl =
      "https://lucky0wl.pythonanywhere.com"; //api website

  static const String baseUrl =
      'http://127.0.0.1:8000'; // Base URL for your API
  static const String authBaseUrl =
      '$baseUrl/api/auth'; // Specific base for auth
  static const String loginEndpoint = '$authBaseUrl/login/';
  static const String registerEndpoint = '$authBaseUrl/register/';
  static const String verifyEmailEndpoint = '$authBaseUrl/verify-email/';
  static const String requestOtpEndpoint = '$authBaseUrl/request-otp/';
  static const String tokenRefreshEndpoint = '$authBaseUrl/token/refresh/';
  static const String tokenBlacklistEndpoint = '$authBaseUrl/token/blacklist/';
  static const String profileEndpoint = '$authBaseUrl/profile/';
  static const String changePasswordEndpoint = '$authBaseUrl/change-password/';
  static const String verifyOtpForPasswordEndpoint =
      '$authBaseUrl/verify-otp-for-password/';
  static const String resetPasswordEndpoint = '$authBaseUrl/reset-password/';
}
