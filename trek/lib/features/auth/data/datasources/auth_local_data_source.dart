import 'package:hive/hive.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> registerUser(UserModel user);
  Future<UserModel?> authenticateUser(String email, String password);
  Future<UserModel?> getUserByEmail(String email);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String userId);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String usersBoxName = 'usersBox';

  @override
  Future<void> registerUser(UserModel user) async {
    final box = await Hive.openBox<UserModel>(usersBoxName);
    if (box.values.any((u) => u.email == user.email)) {
      throw Exception('User already exists');
    }
    await box.add(user);
  }

  @override
  Future<UserModel?> authenticateUser(String email, String password) async {
    final box = await Hive.openBox<UserModel>(usersBoxName);
    try {
      return box.values.firstWhere((u) => u.email == email && u.password == password);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final box = await Hive.openBox<UserModel>(usersBoxName);
    try {
      return box.values.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final box = await Hive.openBox<UserModel>(usersBoxName);
    final existingUser = await getUserByEmail(user.email);
    if (existingUser != null) {
      final index = box.values.toList().indexOf(existingUser);
      await box.putAt(index, user);
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    final box = await Hive.openBox<UserModel>(usersBoxName);
    final user = box.values.firstWhere((u) => u.id == userId);
    await user.delete();
  }
} 