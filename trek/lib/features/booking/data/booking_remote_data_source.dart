import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_model.dart';

class BookingRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  BookingRemoteDataSource({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  Future<List<BookingModel>> fetchBookingsForUser(String userId) async {
    print('BookingRemoteDataSource: Fetching bookings for user: $userId');
    final url = '$baseUrl/bookings/user/$userId';
    print('BookingRemoteDataSource: API URL: $url');
    
    final response = await client.get(Uri.parse(url));
    print('BookingRemoteDataSource: Response status: ${response.statusCode}');
    print('BookingRemoteDataSource: Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data;
      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        data = decoded['data'];
      } else {
        print('BookingRemoteDataSource: Unexpected response format: $decoded');
        throw Exception('Unexpected response format');
      }
      print('BookingRemoteDataSource: Parsed ${data.length} bookings');
      return data.map((json) => BookingModel.fromJson(json)).toList();
    } else {
      print('BookingRemoteDataSource: Failed to load bookings. Status: ${response.statusCode}, Body: ${response.body}');
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

  Future<List<BookingModel>> fetchAllBookings() async {
    final response = await client.get(Uri.parse('$baseUrl/bookings'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data;
      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        data = decoded['data'];
      } else {
        throw Exception('Unexpected response format');
      }
      return data.map((json) => BookingModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }
} 