import '../datasources/package_remote_data_source.dart';
import '../models/package_model.dart';

abstract class PackageRepository {
  Future<List<PackageModel>> getAllPackages();
  Future<PackageModel> getPackageById(String id);
}

class PackageRepositoryImpl implements PackageRepository {
  final PackageRemoteDataSource remoteDataSource;

  PackageRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PackageModel>> getAllPackages() {
    return remoteDataSource.getAllPackages();
  }

  @override
  Future<PackageModel> getPackageById(String id) {
    return remoteDataSource.getPackageById(id);
  }
} 