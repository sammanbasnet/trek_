// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageModel _$PackageModelFromJson(Map<String, dynamic> json) => PackageModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as String,
      image: json['image'] as String,
      availableDates: (json['availableDates'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      category: json['category'] as String,
      itinerary:
          (json['itinerary'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PackageModelToJson(PackageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'price': instance.price,
      'duration': instance.duration,
      'image': instance.image,
      'availableDates':
          instance.availableDates.map((e) => e.toIso8601String()).toList(),
      'category': instance.category,
      'itinerary': instance.itinerary,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
