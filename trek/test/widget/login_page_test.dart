import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trek/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trek/features/auth/domain/repositories/auth_repository.dart';
import 'package:trek/features/auth/presentation/view/login_page.dart';
import 'package:dartz/dartz.dart';
import 'package:trek/features/auth/domain/entities/user_entity.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<String, UserEntity>> login(String email, String password) async => Left('Not implemented');
  @override
  Future<Either<String, UserEntity>> register(UserEntity user, String password) async => Left('Not implemented');
  @override
  Future<Either<String, void>> logout() async => Right(null);
  @override
  Future<bool> isLoggedIn() async => false;
  @override
  Future<Either<String, UserEntity>> getCurrentUser() async => Left('Not implemented');
  @override
  Future<Either<String, UserEntity>> updateProfile(UserEntity user) async => Left('Not implemented');
}

void main() {
  testWidgets('LoginPage renders email and password fields', (WidgetTester tester) async {
    final authBloc = AuthBloc(authRepository: FakeAuthRepository());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginPage(),
        ),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);
  });
} 