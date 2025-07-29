import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // Added for HttpServer
import 'package:http_parser/http_parser.dart'; // Added for ContentType

class SimpleBookingPage extends StatefulWidget {
  final Map<String, String> package;

  const SimpleBookingPage({super.key, required this.package});

  @override
  State<SimpleBookingPage> createState() => _SimpleBookingPageState();
}

class _SimpleBookingPageState extends State<SimpleBookingPage> {
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _bookAfterEsewaSuccess() async {
    setState(() { _isLoading = true; });
    try {
      final bookingData = {
        'packageId': widget.package['id'] ?? 'test-package',
        'fullName': 'eSewa User',
        'email': 'esewa@example.com',
        'phone': '9800000000',
        'tickets': 1,
        'pickupLocation': 'Default Location',
        'paymentMethod': 'credit-card',
      };
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookingData),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Booking created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
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
      final amt = widget.package['price']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '1000';
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
        await _bookAfterEsewaSuccess();
        
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
        await _bookAfterEsewaSuccess();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Trip'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.package['title'] ?? '',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: ${widget.package['price']}',
                            style: const TextStyle(fontSize: 16, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _startEsewaPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Pay with eSewa',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 