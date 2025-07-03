import 'package:json_annotation/json_annotation.dart';

part 'package_model.g.dart';

@JsonSerializable()
class PackageModel {
  @JsonKey(name: '_id')
  final String? id;
  
  final String name;
  final String description;
  final double price;
  final int duration;
  final String destination;
  final String? image;
  final List<String> highlights;
  final List<String> included;
  final List<String> excluded;
  final String difficulty;
  final int maxGroupSize;
  final bool isActive;
  
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  PackageModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.destination,
    this.image,
    required this.highlights,
    required this.included,
    required this.excluded,
    required this.difficulty,
    required this.maxGroupSize,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => _$PackageModelFromJson(json);
  Map<String, dynamic> toJson() => _$PackageModelToJson(this);

  PackageModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? duration,
    String? destination,
    String? image,
    List<String>? highlights,
    List<String>? included,
    List<String>? excluded,
    String? difficulty,
    int? maxGroupSize,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      destination: destination ?? this.destination,
      image: image ?? this.image,
      highlights: highlights ?? this.highlights,
      included: included ?? this.included,
      excluded: excluded ?? this.excluded,
      difficulty: difficulty ?? this.difficulty,
      maxGroupSize: maxGroupSize ?? this.maxGroupSize,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 