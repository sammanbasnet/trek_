import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<String, UserEntity>> register(UserEntity user, String password);
  Future<Either<String, UserEntity>> login(String email, String password);
  Future<Either<String, UserEntity>> getCurrentUser();
  Future<Either<String, UserEntity>> updateProfile(UserEntity user);
  Future<Either<String, void>> logout();
  Future<bool> isLoggedIn();
} 