class BookingModel {
  final String id;
  final String userId;
  final String packageId;
  final DateTime date;
  final int numPeople;
  final double totalPrice;

  BookingModel({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.date,
    required this.numPeople,
    required this.totalPrice,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json['_id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    packageId: json['packageId']?.toString() ?? '',
    date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    numPeople: json['numPeople'] is int ? json['numPeople'] : int.tryParse(json['numPeople']?.toString() ?? '1') ?? 1,
    totalPrice: json['totalPrice'] is double ? json['totalPrice'] : double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'packageId': packageId,
    'date': date.toIso8601String(),
    'numPeople': numPeople,
    'totalPrice': totalPrice,
  };
} 