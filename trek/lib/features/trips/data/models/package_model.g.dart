// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageModel _$PackageModelFromJson(Map<String, dynamic> json) => PackageModel(
      id: json['_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      destination: json['destination'] as String,
      image: json['image'] as String?,
      highlights: (json['highlights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      included:
          (json['included'] as List<dynamic>).map((e) => e as String).toList(),
      excluded:
          (json['excluded'] as List<dynamic>).map((e) => e as String).toList(),
      difficulty: json['difficulty'] as String,
      maxGroupSize: (json['maxGroupSize'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PackageModelToJson(PackageModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'duration': instance.duration,
      'destination': instance.destination,
      'image': instance.image,
      'highlights': instance.highlights,
      'included': instance.included,
      'excluded': instance.excluded,
      'difficulty': instance.difficulty,
      'maxGroupSize': instance.maxGroupSize,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
