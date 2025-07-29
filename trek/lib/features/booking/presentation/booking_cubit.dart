import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/booking_repository_impl.dart';
import '../data/booking_model.dart';

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
} 