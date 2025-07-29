import 'dart:io';

class ApiEndpoints {
  /// Returns the correct base URL depending on environment.
  ///
  /// - If you run with --dart-define=API_BASE_URL=... it will use that.
  /// - Otherwise, uses 10.0.2.2 for emulator, or fallback to localhost.
  static String get baseUrl {
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) return envBaseUrl;
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String getCustomer = '/customers/';
  static const String updateCustomer = '/customers/update/';
  static const String uploadImage = '/customers/uploadImage';

  // Package/Trip endpoints
  static const String packages = '/package';
  static const String packageById = '/package/';

  // Booking endpoints
  static const String bookings = '/bookings';
  static const String createBooking = '/bookings';
  static const String getBookings = '/bookings';

  // Wishlist endpoints
  static const String wishlist = '/wishlist';
  static const String addToWishlist = '/wishlist';
  static const String removeFromWishlist = '/wishlist/';

  // Khalti payment endpoints
  static const String khaltiPayment = '/api/khalti/payment';
} 