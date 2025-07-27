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
      
      // Create a basic user entity from login response
      // We'll get the full user details later if needed
      final userEntity = UserEntity(
        id: loginResult['userId'],
        firstName: '', // We'll get this from local storage or skip for now
        lastName: '',
        email: email,
        phone: '',
        image: '',
        role: loginResult['role'] ?? 'customer',
      );
      
      // Store user info locally for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_id', loginResult['userId']);
      await prefs.setString('user_role', loginResult['role'] ?? 'customer');
      
      return Right(userEntity);
    } catch (e) {
      print('Remote login failed: $e');
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
        print('Local login failed: $localError');
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
      final userRole = prefs.getString('user_role');
      final userEmail = prefs.getString('user_email');
      
      if (userId != null) {
        // Return basic user info from local storage
        return Right(UserEntity(
          id: userId,
          firstName: '', // We can add this later if needed
          lastName: '',
          email: userEmail ?? '', // Get email from local storage
          phone: '',
          image: '',
          role: userRole ?? 'customer',
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