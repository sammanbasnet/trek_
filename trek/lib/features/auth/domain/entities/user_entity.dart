import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? password;
  final String? image;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.password,
    this.image,
    this.role = 'customer',
    this.createdAt,
    this.updatedAt,
  });

  // Getter for full name
  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    password,
    image,
    role,
    createdAt,
    updatedAt,
  ];
} 