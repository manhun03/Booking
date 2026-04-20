class AppConstants {
  // App info
  static const String appName = 'HHBN Booking';
  static const String appVersion = '1.0.0';
  static const String apiBaseUrl =
      'http://localhost:3000/api'; // Change to your API URL

  // Durations
  static const Duration splashScreenDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);

  // Padding and margins
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border radius
  static const double defaultBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double smallBorderRadius = 4.0;

  // Font sizes
  static const double largeHeadline = 28.0;
  static const double mediumHeadline = 24.0;
  static const double smallHeadline = 20.0;
  static const double bodyTextLarge = 16.0;
  static const double bodyTextMedium = 14.0;
  static const double bodyTextSmall = 12.0;
  static const double labelText = 13.0;

  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String googleLoginEndpoint = '/auth/google';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';

  // Local storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';

  // Error messages
  static const String networkError =
      'Network error occurred. Please check your connection.';
  static const String serverError =
      'Server error occurred. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String invalidCredentials = 'Invalid email or password.';
}
