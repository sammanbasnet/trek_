import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<String, UserEntity>> login(String email, String password) async {
    try {
      // Try remote login first
      final loginResult = await remoteDataSource.login(email, password);
      
      // Get user details from remote
      final user = await remoteDataSource.getCurrentUser(loginResult['userId']);
      
      // Store user locally for offline access
      await localDataSource.registerUser(user);
      
      return Right(UserEntity(
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        image: user.image,
        role: user.role,
      ));
    } catch (e) {
      // Fallback to local authentication if remote fails
      try {
        final localUser = await localDataSource.authenticateUser(email, password);
        if (localUser != null) {
          return Right(UserEntity(
            id: localUser.id,
            firstName: localUser.firstName,
            lastName: localUser.lastName,
            email: localUser.email,
            phone: localUser.phone,
            image: localUser.image,
            role: localUser.role,
          ));
        }
      } catch (localError) {
        // Both remote and local failed
      }
      
      return Left('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserEntity>> register(UserEntity user, String password) async {
    try {
      final userModel = UserModel(
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        password: password,
        role: user.role,
      );

      // Register with remote server
      final registeredUser = await remoteDataSource.register(userModel);
      
      // Store locally for offline access
      await localDataSource.registerUser(registeredUser);
      
      return Right(UserEntity(
        id: registeredUser.id,
        firstName: registeredUser.firstName,
        lastName: registeredUser.lastName,
        email: registeredUser.email,
        phone: registeredUser.phone,
        image: registeredUser.image,
        role: registeredUser.role,
      ));
    } catch (e) {
      return Left('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserEntity>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        final user = await remoteDataSource.getCurrentUser(userId);
        return Right(UserEntity(
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phone: user.phone,
          image: user.image,
          role: user.role,
        ));
      } else {
        return Left('No user logged in');
      }
    } catch (e) {
      return Left('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserEntity>> updateProfile(UserEntity user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        final userModel = UserModel(
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phone: user.phone,
          image: user.image,
          role: user.role,
        );

        final updatedUser = await remoteDataSource.updateProfile(userId, userModel);
        
        // Update local storage
        await localDataSource.registerUser(updatedUser);
        
        return Right(UserEntity(
          id: updatedUser.id,
          firstName: updatedUser.firstName,
          lastName: updatedUser.lastName,
          email: updatedUser.email,
          phone: updatedUser.phone,
          image: updatedUser.image,
          role: updatedUser.role,
        ));
      } else {
        return Left('No user logged in');
      }
    } catch (e) {
      return Left('Profile update failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }
} 