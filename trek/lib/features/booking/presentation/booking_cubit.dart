import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/booking_repository_impl.dart';
import '../data/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}
class BookingLoading extends BookingState {}
class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;
  BookingLoaded(this.bookings);
}
class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository repository;
  BookingCubit(this.repository) : super(BookingInitial());

  Future<void> fetchBookings(String userId) async {
    emit(BookingLoading());
    try {
      final bookings = await repository.getBookingsForUser(userId);
      emit(BookingLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> fetchAllBookings() async {
    emit(BookingLoading());
    try {
      final bookings = await repository.getAllBookings();
      emit(BookingLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> fetchUserBookings() async {
    emit(BookingLoading());
    try {
      // Get current user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      print('BookingCubit: Current user ID: $userId');
      
      if (userId == null) {
        print('BookingCubit: No user ID found, user not logged in');
        emit(BookingError('User not logged in'));
        return;
      }
      
      print('BookingCubit: Fetching bookings for user: $userId');
      final bookings = await repository.getBookingsForUser(userId);
      print('BookingCubit: Fetched ${bookings.length} bookings');
      emit(BookingLoaded(bookings));
    } catch (e) {
      print('BookingCubit: Error fetching bookings: $e');
      emit(BookingError(e.toString()));
    }
  }
} 