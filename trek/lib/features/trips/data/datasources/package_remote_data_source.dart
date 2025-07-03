import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/package_model.dart';

abstract class PackageRemoteDataSource {
  Future<List<PackageModel>> getAllPackages();
  Future<PackageModel> getPackageById(String id);
}

class PackageRemoteDataSourceImpl implements PackageRemoteDataSource {
  final ApiService _apiService = ApiService();

  @override
  Future<List<PackageModel>> getAllPackages() async {
    try {
      final response = await _apiService.get(ApiEndpoints.packages);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PackageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch packages');
      }
    } catch (e) {
      throw Exception('Failed to fetch packages: ${e.toString()}');
    }
  }

  @override
  Future<PackageModel> getPackageById(String id) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.packageById}$id');
      
      if (response.statusCode == 200) {
        return PackageModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch package');
      }
    } catch (e) {
      throw Exception('Failed to fetch package: ${e.toString()}');
    }
  }
} 