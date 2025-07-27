import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/package_model.dart';

class PackageRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  PackageRemoteDataSource({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  Future<List<PackageModel>> getAllPackages() async {
    try {
      final url = '$baseUrl/package';
      print('PackageRemoteDataSource: Fetching packages from $url');
      final response = await client.get(Uri.parse(url));
      
      print('PackageRemoteDataSource: Response status: ${response.statusCode}');
      print('PackageRemoteDataSource: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('PackageRemoteDataSource: Decoded ${data.length} packages');
        return data.map((json) => PackageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load packages: ${response.statusCode}');
      }
    } catch (e) {
      print('PackageRemoteDataSource: Error: $e');
      throw Exception('Failed to load packages: $e');
    }
  }

  Future<PackageModel> getPackageById(String id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/package/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PackageModel.fromJson(data);
      } else {
        throw Exception('Failed to load package: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load package: $e');
    }
  }
} 