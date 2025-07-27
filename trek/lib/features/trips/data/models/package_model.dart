import 'package:json_annotation/json_annotation.dart';

part 'package_model.g.dart';

@JsonSerializable()
class PackageModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final double price;
  final String duration;
  final String image;
  final List<DateTime> availableDates;
  final String category;
  final List<String> itinerary;
  final DateTime createdAt;
  final DateTime updatedAt;

  PackageModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.duration,
    required this.image,
    required this.availableDates,
    required this.category,
    required this.itinerary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
    id: json['_id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    location: json['location']?.toString() ?? '',
    price: json['price'] is double ? json['price'] : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    duration: json['duration']?.toString() ?? '',
    image: json['image']?.toString() ?? '',
    availableDates: json['availableDates'] != null 
        ? (json['availableDates'] as List).map((date) => DateTime.tryParse(date.toString()) ?? DateTime.now()).toList()
        : [],
    category: json['category']?.toString() ?? '',
    itinerary: json['itinerary'] != null 
        ? (json['itinerary'] as List).map((item) => item.toString()).toList()
        : [],
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'location': location,
    'price': price,
    'duration': duration,
    'image': image,
    'availableDates': availableDates.map((date) => date.toIso8601String()).toList(),
    'category': category,
    'itinerary': itinerary,
  };
} 