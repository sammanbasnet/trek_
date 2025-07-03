import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register(UserModel user);
  Future<Map<String, dynamic>> login(String email, String password);
  Future<UserModel> getCurrentUser(String userId);
  Future<UserModel> updateProfile(String userId, UserModel user);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService = ApiService();

  @override
  Future<UserModel> register(UserModel user) async {
    final data = {
      'fname': user.firstName.isNotEmpty ? user.firstName : 'First',
      'lname': user.lastName.isNotEmpty ? user.lastName : 'Last',
      'email': user.email,
      'phone': user.phone.isNotEmpty ? user.phone : '0000000000',
      'password': user.password ?? '',
      'role': user.role,
    };
    try {
      print('Registration request data: $data');
      final response = await _apiService.post(
        ApiEndpoints.register,
        data: data,
      );

      if (response.statusCode == 201) {
        // Parse the created user from the backend response if present
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          return UserModel.fromJson(responseData['data']);
        }
        return user;
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      print('Registration error response: ${e.response?.data}');
      final errorData = e.response?.data;
      String errorMessage = 'Registration failed';
      if (errorData is Map && errorData['message'] != null) {
        errorMessage = errorData['message'].toString();
      } else if (errorData != null) {
        errorMessage = errorData.toString();
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      // Print the full error data for debugging
      print('Full backend error: $errorData');
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Store token and user ID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_id', data['userId']);
        await prefs.setString('user_role', data['role']);

        return {
          'token': data['token'],
          'userId': data['userId'],
          'role': data['role'],
        };
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser(String userId) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.getCustomer}/$userId');
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile(String userId, UserModel user) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.updateCustomer}/$userId',
        data: {
          'fname': user.firstName,
          'lname': user.lastName,
          'email': user.email,
          'phone': user.phone,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception('Profile update failed');
      }
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
  }
} 