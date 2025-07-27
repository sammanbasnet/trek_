import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/package_repository_impl.dart';
import '../data/models/package_model.dart';

abstract class PackageState {}

class PackageInitial extends PackageState {}
class PackageLoading extends PackageState {}
class PackageLoaded extends PackageState {
  final List<PackageModel> packages;
  PackageLoaded(this.packages);
}
class PackageError extends PackageState {
  final String message;
  PackageError(this.message);
}

class PackageCubit extends Cubit<PackageState> {
  final PackageRepository repository;
  PackageCubit(this.repository) : super(PackageInitial());

  Future<void> fetchPackages() async {
    print('PackageCubit: Starting to fetch packages...');
    emit(PackageLoading());
    try {
      final packages = await repository.getAllPackages();
      print('PackageCubit: Successfully fetched ${packages.length} packages');
      for (var package in packages) {
        print('PackageCubit: Package - ${package.title} (${package.location}) - \$${package.price}');
      }
      emit(PackageLoaded(packages));
    } catch (e) {
      print('PackageCubit: Error fetching packages: $e');
      emit(PackageError(e.toString()));
    }
  }
} 