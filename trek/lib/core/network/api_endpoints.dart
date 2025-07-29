class ApiEndpoints {
  // Base URL - change this to your backend URL when running
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1'; // For Android emulator
  // static const String baseUrl = 'http://localhost:3000/api/v1'; // For iOS simulator
  // static const String baseUrl = 'http://<your-pc-ip>:3000/api/v1'; // For physical device

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