import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../booking_cubit.dart';
import '../../data/booking_repository_impl.dart';
import '../../data/booking_remote_data_source.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    print('BookingsPage: build method called');
    // Get current user ID from SharedPreferences
    Future<String?> getCurrentUserId() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    }
    
    final repository = BookingRepositoryImpl(
      BookingRemoteDataSource(baseUrl: ApiEndpoints.baseUrl),
    );
    return BlocProvider(
      create: (_) {
        final cubit = BookingCubit(repository);
        // Initialize bookings fetch after the cubit is created
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('BookingsPage: Initializing bookings fetch');
          cubit.fetchUserBookings();
        });
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.redAccent.withOpacity(0.1), Colors.white],
            ),
          ),
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              print('BookingsPage: State changed to: ${state.runtimeType}');
              if (state is BookingLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.redAccent),
                      SizedBox(height: 16),
                      Text('Loading your bookings...', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                );
              } else if (state is BookingLoaded) {
                print('BookingsPage: Loaded ${state.bookings.length} bookings');
                if (state.bookings.isEmpty) {
                  print('BookingsPage: No bookings found');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.book_online, size: 80, color: Colors.grey[400]),
                              SizedBox(height: 20),
                              Text(
                                'No bookings yet!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Start your adventure by booking a trip!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to trips page
                                  Navigator.pushNamed(context, '/home');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                ),
                                child: Text(
                                  'Explore Trips',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    // Use the context from BlocBuilder which has access to the provider
                    context.read<BookingCubit>().fetchUserBookings();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: state.bookings.length,
                    itemBuilder: (context, index) {
                      final booking = state.bookings[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Package Image and Header
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                image: DecorationImage(
                                  image: _getPackageImage(booking.packageTitle, booking.packageDetails),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  booking.packageTitle,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  booking.packageLocation,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white.withOpacity(0.9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(booking.status),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              booking.status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Booking Details
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  // User and Ticket Info
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoCard(
                                          Icons.person,
                                          'Name',
                                          booking.fullName,
                                          Colors.blue,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: _buildInfoCard(
                                          Icons.confirmation_number,
                                          'Tickets',
                                          '${booking.tickets}',
                                          Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  // Date and Payment Info
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoCard(
                                          Icons.calendar_today,
                                          'Booked',
                                          _formatDate(booking.createdAt),
                                          Colors.orange,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: _buildInfoCard(
                                          Icons.payment,
                                          'Payment',
                                          booking.paymentMethod.replaceAll('-', ' ').toUpperCase(),
                                          Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  // Price Section
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total Price',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              'Rs. ${booking.totalPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.attach_money,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else if (state is BookingError) {
                return Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error Loading Bookings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<BookingCubit>().fetchUserBookings();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  ImageProvider _getPackageImage(String packageTitle, Map<String, dynamic>? packageDetails) {
    final title = packageTitle.toLowerCase();
    
    print('Package Title: $packageTitle');
    print('Package Details: $packageDetails');
    
    // First try to get the image from package details if available
    if (packageDetails != null && packageDetails['image'] != null) {
      final imageName = packageDetails['image'].toString();
      print('Found image in package details: $imageName');
      if (imageName.isNotEmpty) {
        // Load image from backend uploads folder
        final imageUrl = '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}/uploads/$imageName';
        print('Loading image from: $imageUrl');
        return NetworkImage(imageUrl);
      }
    }
    
    // If no image in package details, try to find a suitable image based on package title
    if (title.contains('dhorpatan')) {
      // Try to find a dhorpatan-related image in uploads
      return NetworkImage('${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}/uploads/IMG-1754168778374.jpg');
    }
    
    // Fallback to mountains image if no specific image found
    print('Using fallback mountains image');
    return AssetImage('assets/image/mountains.jpg');
  }
} 