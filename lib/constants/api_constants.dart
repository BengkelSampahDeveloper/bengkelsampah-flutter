class ApiConstants {
  static const String baseUrl = 'https://bengkelsampah.com/api';

  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String sendOtp = '/send-otp';
  static const String forgotPassword = '/forgot';
  static const String logout = '/logout';

  // User endpoints
  static const String home = '/home';
  static const String points = '/point';
  static const String profile = '/profile';
  static const String detailProfile = '/detail-profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/profile/change-password';
  static const String addresses = '/addresses';

  // Article endpoints
  static const String articles = '/artikels';

  // Event endpoints
  static const String events = '/events';

  // Bank Sampah endpoints
  static const String bankSampah = '/bank-sampah';

  // Katalog endpoints
  static const String katalog = '/katalog';
  // Pilahku check endpoint
  static const String pilahkuCheck = '/pilahku/check';

  // Setoran endpoints
  static const String setorans = '/setorans';
  static const String cancelSetoran = '/setorans/{id}/cancel';
}
