import 'booking_remote_data_source.dart';
import 'booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getBookingsForUser(String userId);
  Future<List<BookingModel>> getAllBookings();
  Future<void> createBooking(Map<String, dynamic> bookingData);
}

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BookingModel>> getBookingsForUser(String userId) {
    return remoteDataSource.fetchBookingsForUser(userId);
  }

  @override
  Future<List<BookingModel>> getAllBookings() {
    return remoteDataSource.fetchAllBookings();
  }

  @override
  Future<void> createBooking(Map<String, dynamic> bookingData) {
    return remoteDataSource.createBooking(bookingData);
  }
} 