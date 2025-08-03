import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class SimpleBookingPage extends StatefulWidget {
  final Map<String, dynamic> package;

  const SimpleBookingPage({super.key, required this.package});

  @override
  State<SimpleBookingPage> createState() => _SimpleBookingPageState();
}

class _SimpleBookingPageState extends State<SimpleBookingPage> {
  bool _isLoading = false;
  String? _selectedPaymentMethod;
  int _ticketCount = 1;
  Position? _currentPosition;
  String _currentAddress = 'Getting location...';
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _currentAddress = 'Getting location...';
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location services disabled';
          _isGettingLocation = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = 'Location permission denied';
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = 'Location permission permanently denied';
          _isGettingLocation = false;
        });
        return;
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
      });

      // Get address from coordinates
      await _getAddressFromCoordinates(position);
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _currentAddress = 'Location unavailable - using default';
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';
        
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }

        setState(() {
          _currentAddress = address.isNotEmpty ? address : 'Location found';
        });
      } else {
        setState(() {
          _currentAddress = 'Location found (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _currentAddress = 'Location found (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      });
    }
  }

  double get _totalPrice {
    final price = widget.package['price'];
    double basePrice;
    
    if (price is int) {
      basePrice = price.toDouble();
    } else if (price is double) {
      basePrice = price;
    } else if (price is String) {
      basePrice = double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 1000.0;
    } else {
      basePrice = 1000.0;
    }
    
    return basePrice * _ticketCount;
  }

  String get _formattedPrice {
    return '\$${_totalPrice.toStringAsFixed(0)} /visit';
  }

  Future<String?> _getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('user_firstName') ?? '';
    final lastName = prefs.getString('user_lastName') ?? '';
    
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    
    // Fallback to email username
    final email = prefs.getString('user_email') ?? '';
    if (email.isNotEmpty) {
      final username = email.split('@')[0];
      return username.isNotEmpty ? username : 'Trek User';
    }
    
    return 'Trek User';
  }

  Future<void> _bookAfterPaymentSuccess(String paymentMethod) async {
    setState(() { _isLoading = true; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      final userId = prefs.getString('user_id');
      final fullName = await _getCurrentUserName();

      if (userEmail == null || userId == null) {
        throw Exception('User not logged in');
      }

      final bookingData = {
        'userId': userId,
        'packageId': widget.package['id'],
        'packageTitle': widget.package['title'],
        'fullName': fullName,
        'email': userEmail,
        'phone': '9800000000',
        'tickets': _ticketCount,
        'pickupLocation': _currentAddress,
        'paymentMethod': paymentMethod,
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
      };

      print('Creating booking with data: $bookingData');

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookingData),
      );

      print('Booking response status: ${response.statusCode}');
      print('Booking response body: ${response.body}');

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<!DOCTYPE html>') || response.body.trim().startsWith('<html')) {
        throw Exception('Server returned HTML instead of JSON. Please check if the backend server is running.');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Clear any previous snackbars
        ScaffoldMessenger.of(context).clearSnackBars();
        
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Navigate back after successful booking
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        } else {
          final errorMessage = responseData['message'] ?? 'Failed to create booking';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to create booking';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error creating booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _handleEsewaPayment() async {
    setState(() { _isLoading = true; });
    try {
      // Show loading message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Processing eSewa payment...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );

      // Show mock eSewa payment dialog
      final paymentResult = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
                         decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(20),
               gradient: LinearGradient(
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
                 colors: [Colors.green.shade400, Colors.green.shade600],
               ),
             ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // eSewa Logo and Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                                             child: Icon(Icons.payment, color: Colors.green.shade600, size: 32),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'eSewa',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Digital Payment Gateway',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                
                // Payment Details Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Amount Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount to Pay:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                                                     Text(
                             '\$${_totalPrice.toStringAsFixed(0)}',
                             style: TextStyle(
                               fontSize: 24,
                               fontWeight: FontWeight.bold,
                               color: Colors.green.shade600,
                             ),
                           ),
                        ],
                      ),
                      SizedBox(height: 20),
                      
                      // Payment Method Selection
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                                                         Icon(Icons.account_balance_wallet, color: Colors.green.shade600, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'eSewa Wallet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    'Pay using your eSewa balance',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                                                         Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Processing Animation
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                                                         child: CircularProgressIndicator(
                               strokeWidth: 2,
                               valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                             ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Processing payment...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                                                 style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.white,
                           foregroundColor: Colors.green.shade600,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Confirm Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (paymentResult == true) {
        // Simulate payment processing
        await Future.delayed(Duration(seconds: 2));
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('eSewa payment successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Create booking after successful payment
        await _bookAfterPaymentSuccess('esewa');
      }
    } catch (e) {
      print('eSewa payment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _handleCashOnArrival() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cash on Arrival'),
        content: Text('You have selected Cash on Arrival payment. Your booking will be confirmed and you can pay when you arrive. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _bookAfterPaymentSuccess('cash-on-arrival');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Trip', style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Info Card
              Container(
                width: double.infinity,
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
                                 child: Padding(
                   padding: const EdgeInsets.all(20),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       // Package Image and Info Row
                       Row(
                         children: [
                           // Package Image
                           Container(
                             width: 80,
                             height: 80,
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(12),
                               boxShadow: [
                                 BoxShadow(
                                   color: Colors.grey.withOpacity(0.3),
                                   spreadRadius: 1,
                                   blurRadius: 5,
                                   offset: Offset(0, 2),
                                 ),
                               ],
                             ),
                             child: ClipRRect(
                               borderRadius: BorderRadius.circular(12),
                               child: Image.network(
                                 widget.package['image'] ?? 'https://via.placeholder.com/80x80',
                                 width: 80,
                                 height: 80,
                                 fit: BoxFit.cover,
                                 loadingBuilder: (context, child, loadingProgress) {
                                   if (loadingProgress == null) return child;
                                   return Container(
                                     color: Colors.grey[300],
                                     child: Center(
                                       child: CircularProgressIndicator(
                                         value: loadingProgress.expectedTotalBytes != null
                                             ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                             : null,
                                         strokeWidth: 2,
                                       ),
                                     ),
                                   );
                                 },
                                 errorBuilder: (context, error, stackTrace) {
                                   return Container(
                                     color: Colors.grey[300],
                                     child: Icon(Icons.card_travel, color: Colors.redAccent, size: 30),
                                   );
                                 },
                               ),
                             ),
                           ),
                           SizedBox(width: 16),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   widget.package['title'] ?? 'Trek Package',
                                   style: TextStyle(
                                     fontSize: 18,
                                     fontWeight: FontWeight.bold,
                                     color: Colors.grey[800],
                                   ),
                                 ),
                                 SizedBox(height: 4),
                                 Text(
                                   widget.package['location'] ?? 'Nepal',
                                   style: TextStyle(
                                     fontSize: 14,
                                     color: Colors.grey[600],
                                   ),
                                 ),
                                 SizedBox(height: 8),
                                 Row(
                                   children: [
                                     Icon(Icons.star, color: Colors.amber, size: 16),
                                     SizedBox(width: 4),
                                     Text(
                                       widget.package['rating']?.toString() ?? '4.5',
                                       style: TextStyle(
                                         fontSize: 14,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.grey[700],
                                       ),
                                     ),
                                     SizedBox(width: 16),
                                     Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                                     SizedBox(width: 4),
                                     Text(
                                       widget.package['duration'] ?? '14 days',
                                       style: TextStyle(
                                         fontSize: 14,
                                         color: Colors.grey[600],
                                       ),
                                     ),
                                   ],
                                 ),
                               ],
                             ),
                           ),
                         ],
                       ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tickets',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: _ticketCount > 1 ? () {
                                    setState(() {
                                      _ticketCount--;
                                    });
                                  } : null,
                                  icon: Icon(Icons.remove, color: Colors.white),
                                  constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$_ticketCount',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: _ticketCount < 10 ? () {
                                    setState(() {
                                      _ticketCount++;
                                    });
                                  } : null,
                                  icon: Icon(Icons.add, color: Colors.white),
                                  constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Price:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            _formattedPrice,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Location Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Pickup Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Spacer(),
                        if (_isGettingLocation)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      _currentAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _getCurrentLocation,
                          icon: Icon(Icons.refresh, color: Colors.blue, size: 18),
                          tooltip: 'Refresh Location',
                        ),
                        Text(
                          'Tap to refresh location',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Payment Methods
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 15),
              
              // eSewa Payment Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'esewa';
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedPaymentMethod == 'esewa' ? Colors.orange.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPaymentMethod == 'esewa' ? Colors.orange : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.payment, color: Colors.orange.shade700, size: 24),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'eSewa',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pay securely with eSewa',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedPaymentMethod == 'esewa')
                        Icon(Icons.check_circle, color: Colors.orange, size: 24),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 12),
              
              // Cash on Arrival Payment Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'cash-on-arrival';
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedPaymentMethod == 'cash-on-arrival' ? Colors.green.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPaymentMethod == 'cash-on-arrival' ? Colors.green : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.money, color: Colors.green.shade700, size: 24),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cash on Arrival',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pay when you arrive',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedPaymentMethod == 'cash-on-arrival')
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 30),
              
              // Book Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || _selectedPaymentMethod == null
                      ? null
                      : () {
                          if (_selectedPaymentMethod == 'esewa') {
                            _handleEsewaPayment();
                          } else if (_selectedPaymentMethod == 'cash-on-arrival') {
                            _handleCashOnArrival();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPaymentMethod == 'esewa' ? Colors.orange : 
                                   _selectedPaymentMethod == 'cash-on-arrival' ? Colors.green : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _selectedPaymentMethod == 'esewa' ? 'Pay with eSewa' :
                          _selectedPaymentMethod == 'cash-on-arrival' ? 'Confirm Cash on Arrival' :
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 