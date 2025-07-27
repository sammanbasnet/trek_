import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_model.dart';

class BookingRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  BookingRemoteDataSource({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  Future<List<BookingModel>> fetchBookingsForUser(String userId) async {
    final response = await client.get(Uri.parse('$baseUrl/bookings/user/$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BookingModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final url = '$baseUrl/bookings';
      print('BookingRemoteDataSource: Creating booking at $url');
      print('BookingRemoteDataSource: Booking data: $bookingData');
      
      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookingData),
      );
      
      print('BookingRemoteDataSource: Response status: ${response.statusCode}');
      print('BookingRemoteDataSource: Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        print('BookingRemoteDataSource: Booking created successfully');
        return;
      } else {
        print('BookingRemoteDataSource: Failed to create booking: ${response.statusCode}');
        throw Exception('Failed to create booking: ${response.body}');
      }
    } catch (e) {
      print('BookingRemoteDataSource: Error creating booking: $e');
      throw Exception('Failed to create booking: $e');
    }
  }
} 