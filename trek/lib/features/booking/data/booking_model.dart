class BookingModel {
  final String id;
  final String packageId;
  final String fullName;
  final String email;
  final String phone;
  final int tickets;
  final String pickupLocation;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? packageDetails;

  BookingModel({
    required this.id,
    required this.packageId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.tickets,
    required this.pickupLocation,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.packageDetails,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Handle both direct booking data and populated package data
    Map<String, dynamic>? packageData;
    if (json['packageId'] is Map<String, dynamic>) {
      packageData = json['packageId'] as Map<String, dynamic>;
    }
    
    return BookingModel(
      id: json['_id']?.toString() ?? '',
      packageId: json['packageId'] is String 
          ? json['packageId'] 
          : json['packageId']?['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      tickets: json['tickets'] is int ? json['tickets'] : int.tryParse(json['tickets']?.toString() ?? '1') ?? 1,
      pickupLocation: json['pickupLocation']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      packageDetails: packageData,
    );
  }

  Map<String, dynamic> toJson() => {
    'packageId': packageId,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'tickets': tickets,
    'pickupLocation': pickupLocation,
    'paymentMethod': paymentMethod,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  // Helper methods for display
  String get packageTitle => packageDetails?['title']?.toString() ?? 'Unknown Package';
  String get packageLocation => packageDetails?['location']?.toString() ?? '';
  String get packagePrice => packageDetails?['price']?.toString() ?? '0';
  String get packageDuration => packageDetails?['duration']?.toString() ?? '';
  
  double get totalPrice {
    if (packageDetails?['price'] != null) {
      final priceStr = packageDetails!['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
      return (double.tryParse(priceStr) ?? 0.0) * tickets;
    }
    return 0.0;
  }
} 