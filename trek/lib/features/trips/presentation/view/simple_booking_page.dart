import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_endpoints.dart';

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

  @override
  void dispose() {
    super.dispose();
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
    final firstName = prefs.getString('firstName') ?? '';
    final lastName = prefs.getString('lastName') ?? '';
    
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    
    // Fallback to email username
    final email = prefs.getString('email') ?? '';
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
      final userEmail = prefs.getString('email');
      final userId = prefs.getString('userId');
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
        'pickupLocation': 'Default Location',
        'paymentMethod': paymentMethod,
      };

      print('Creating booking with data: $bookingData');

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/booking'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookingData),
      );

      print('Booking response status: ${response.statusCode}');
      print('Booking response body: ${response.body}');

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
      final mockPaymentUrl = 'https://mock-payment-gateway.vercel.app/esewa';

      // Payment details
      final amt = _totalPrice.toStringAsFixed(0);
      final pid = widget.package['id'] ?? 'test-package';

      // Show loading message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redirecting to eSewa payment...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );

      // Simulate payment process
      await Future.delayed(Duration(seconds: 2));

      // Simulate successful payment
      await _bookAfterPaymentSuccess('esewa');
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