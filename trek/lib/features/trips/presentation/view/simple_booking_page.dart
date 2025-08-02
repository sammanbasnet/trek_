import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // Added for HttpServer
import 'package:http_parser/http_parser.dart'; // Added for ContentType
import 'package:shared_preferences/shared_preferences.dart';

class SimpleBookingPage extends StatefulWidget {
  final Map<String, String> package;

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
    final basePrice = double.tryParse(widget.package['price']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '1000') ?? 1000.0;
    return basePrice * _ticketCount;
  }

  String get _formattedPrice {
    return '\$${_totalPrice.toStringAsFixed(0)} /visit';
  }

  Future<void> _bookAfterPaymentSuccess(String paymentMethod) async {
    setState(() { _isLoading = true; });
    try {
      // Get current user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userEmail = prefs.getString('user_email');
      
      print('Booking: User ID from SharedPreferences: $userId');
      print('Booking: User Email from SharedPreferences: $userEmail');
      
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error: User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() { _isLoading = false; });
        return;
      }
      
      final bookingData = {
        'userId': userId,
        'packageId': widget.package['id'] ?? 'test-package',
        'fullName': 'Trek User',
        'email': userEmail ?? 'user@example.com',
        'phone': '9800000000',
        'tickets': _ticketCount,
        'pickupLocation': 'Default Location',
        'paymentMethod': paymentMethod,
      };
      
      print('Booking: Creating booking with data: $bookingData');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookingData),
      );
      
      print('Booking: Response status: ${response.statusCode}');
      print('Booking: Response body: ${response.body}');
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 201 && responseData['success'] == true) {
        // Clear any existing snackbars first
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${responseData['message'] ?? 'Booking created successfully with $paymentMethod!'}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Navigate back to previous page after a short delay
        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      } else {
        // Clear any existing snackbars first
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${responseData['error'] ?? 'Failed to create booking'}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Clear any existing snackbars first
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Network Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _startEsewaPayment() async {
    setState(() { _isLoading = true; });
    
    try {
      // eSewa test merchant code and URLs
      final esewaMerchantCode = 'EPAYTEST';
      // Since eSewa test environment is down, we'll create a mock payment gateway
      final mockPaymentUrl = 'https://mock-payment-gateway.vercel.app/esewa';
      
      // Payment details
      final amt = _totalPrice.toStringAsFixed(0);
      final pid = widget.package['id'] ?? 'test-package';
      
      // Show loading message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening eSewa payment gateway...'),
          backgroundColor: Colors.blue,
        ),
      );
      
      // Create a simple HTTP server to serve the eSewa payment form
      final server = await HttpServer.bind('localhost', 0);
      final port = server.port;
      
      // Handle the payment form request
      server.listen((HttpRequest request) async {
        if (request.uri.path == '/') {
          // Serve the eSewa payment form
          final html = '''
            <!DOCTYPE html>
            <html>
            <head>
              <title>eSewa Payment</title>
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <style>
                body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
                .container { max-width: 400px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                .header { text-align: center; margin-bottom: 20px; }
                .details { margin-bottom: 20px; }
                .details p { margin: 8px 0; }
                .button { width: 100%; padding: 15px; background: #4CAF50; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; }
                .button:hover { background: #45a049; }
                .note { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
                .payment-form { margin-top: 20px; }
                .form-group { margin-bottom: 15px; }
                .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
                .form-group input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
                .success { background: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin-top: 20px; }
              </style>
            </head>
            <body>
              <div class="container">
                <div class="header">
                  <h2>eSewa Payment Gateway</h2>
                </div>
                <div class="details">
                  <p><strong>Package:</strong> ${widget.package['title'] ?? 'Trek Package'}</p>
                  <p><strong>Amount:</strong> Rs. $amt</p>
                  <p><strong>Payment ID:</strong> $pid</p>
                </div>
                
                <div id="paymentForm">
                  <div class="payment-form">
                    <h3>Test Payment Details</h3>
                    <div class="form-group">
                      <label>eSewa ID / Mobile Number:</label>
                      <input type="text" id="esewaId" value="test@esewa.com.np" placeholder="Enter eSewa ID">
                    </div>
                    <div class="form-group">
                      <label>MPIN:</label>
                      <input type="password" id="mpin" value="1234" placeholder="Enter MPIN">
                    </div>
                    <button onclick="processPayment()" class="button">
                      Pay Rs. $amt
                    </button>
                  </div>
                </div>
                
                <div id="successMessage" style="display: none;" class="success">
                  <h3>Payment Successful!</h3>
                  <p>Transaction ID: TXN_${DateTime.now().millisecondsSinceEpoch}</p>
                  <p>Amount: Rs. $amt</p>
                  <p>Status: Completed</p>
                </div>
                
                <div class="note">
                  This is a mock payment gateway for testing purposes
                </div>
              </div>
              <script>
                function processPayment() {
                  const esewaId = document.getElementById('esewaId').value;
                  const mpin = document.getElementById('mpin').value;
                  
                  if (!esewaId || !mpin) {
                    alert('Please enter both eSewa ID and MPIN');
                    return;
                  }
                  
                  // Hide payment form and show success
                  document.getElementById('paymentForm').style.display = 'none';
                  document.getElementById('successMessage').style.display = 'block';
                  
                  // Simulate payment processing
                  setTimeout(function() {
                    // Send success message to Flutter app
                    if (window.flutter_inappwebview) {
                      window.flutter_inappwebview.callHandler('paymentSuccess', {
                        transactionId: 'TXN_' + Date.now(),
                        amount: '$amt',
                        status: 'success'
                      });
                    }
                  }, 2000);
                }
              </script>
            </body>
            </html>
          ''';
          
          request.response
            ..headers.contentType = ContentType.html
            ..write(html)
            ..close();
        }
      });
      
      // Open the local server URL in browser
      final localUrl = 'http://localhost:$port';
      final launched = await launchUrl(
        Uri.parse(localUrl),
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('eSewa payment gateway opened! Please complete payment.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Wait for payment completion then create booking
        await Future.delayed(const Duration(seconds: 10));
        await _bookAfterPaymentSuccess('esewa');
        
        // Close the server
        server.close();
      } else {
        // Fallback: create booking directly
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open payment gateway. Creating booking directly...'),
            backgroundColor: Colors.orange,
          ),
        );
        await _bookAfterPaymentSuccess('esewa');
        server.close();
      }
      
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('Error: $e'),
           backgroundColor: Colors.red,
         ),
       );
     } finally {
       setState(() { _isLoading = false; });
     }
   }

  Future<void> _handleCashOnArrival() async {
    setState(() { _isLoading = true; });
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.money, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Cash on Arrival', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You have selected to pay in cash upon arrival.'),
              SizedBox(height: 10),
              Text('Number of people: $_ticketCount', 
                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
              SizedBox(height: 10),
              Text('Amount to pay: $_formattedPrice', 
                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              SizedBox(height: 10),
              Text('Please ensure you have the exact amount ready when you arrive at the pickup location.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Confirm Booking', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _bookAfterPaymentSuccess('cash-on-arrival');
    } else {
      setState(() { _isLoading = false; });
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Details Card
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
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.card_travel, color: Colors.redAccent, size: 24),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.package['title'] ?? 'Trek Package',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Adventure awaits!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.green, size: 24),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
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
                                    _formattedPrice,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
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
                ),
              ),
              
              SizedBox(height: 30),
              
              // Ticket Counter Section
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
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.people, color: Colors.blue, size: 24),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Number of People',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Select how many people are joining',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
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
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
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
                                  _formattedPrice,
                                  style: TextStyle(
                                    fontSize: 20,
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
              ),
              
              SizedBox(height: 30),
              
              // Payment Options
              Text(
                'Choose Payment Method',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 20),
              
              // eSewa Payment Option
              GestureDetector(
                onTap: () => setState(() => _selectedPaymentMethod = 'esewa'),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedPaymentMethod == 'esewa' ? Colors.green.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _selectedPaymentMethod == 'esewa' ? Colors.green : Colors.grey.withOpacity(0.3),
                      width: _selectedPaymentMethod == 'esewa' ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.payment, color: Colors.green, size: 24),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pay with eSewa',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Secure online payment',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedPaymentMethod == 'esewa')
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 15),
              
              // Cash on Arrival Option
              GestureDetector(
                onTap: () => setState(() => _selectedPaymentMethod = 'cash'),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedPaymentMethod == 'cash' ? Colors.orange.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _selectedPaymentMethod == 'cash' ? Colors.orange : Colors.grey.withOpacity(0.3),
                      width: _selectedPaymentMethod == 'cash' ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.money, color: Colors.orange, size: 24),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cash on Arrival',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Pay when you arrive',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedPaymentMethod == 'cash')
                        Icon(Icons.check_circle, color: Colors.orange, size: 24),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 30),
              
              // Proceed Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading || _selectedPaymentMethod == null
                      ? null
                      : _selectedPaymentMethod == 'esewa'
                          ? _startEsewaPayment
                          : _handleCashOnArrival,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPaymentMethod == 'esewa' ? Colors.green : Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _selectedPaymentMethod == 'esewa'
                              ? 'Pay with eSewa'
                              : 'Confirm Cash Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Additional Info
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your booking will be confirmed immediately. For cash payments, please bring exact change.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 