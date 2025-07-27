import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../booking_cubit.dart';
import '../../data/booking_repository_impl.dart';
import '../../data/booking_remote_data_source.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual userId from auth
    const userId = 'USER_ID';
    final repository = BookingRepositoryImpl(
      BookingRemoteDataSource(baseUrl: 'http://192.168.1.16:3000/api/v1'),
    );
    return BlocProvider(
      create: (_) => BookingCubit(repository)..fetchBookings(userId),
      child: Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        automaticallyImplyLeading: false,
      ),
        body: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            if (state is BookingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BookingLoaded) {
              if (state.bookings.isEmpty) {
                return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_online, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text('You have no bookings yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 10),
            Text('Book a trip to see it here!', style: TextStyle(color: Colors.grey)),
          ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.bookings.length,
                itemBuilder: (context, index) {
                  final booking = state.bookings[index];
                  return ListTile(
                    leading: const Icon(Icons.book_online),
                    title: Text('Package:  ${booking.packageId}'),
                    subtitle: Text('Date:  ${booking.date.toLocal()}\nPeople:  ${booking.numPeople}'),
                    trailing: Text('Rs.  ${booking.totalPrice.toStringAsFixed(2)}'),
                  );
                },
              );
            } else if (state is BookingError) {
              return Center(child: Text('Error:  ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
} 