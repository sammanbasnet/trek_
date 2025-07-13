import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:trek/features/auth/domain/entities/user_entity.dart';
import 'package:trek/features/auth/domain/repositories/auth_repository.dart';
import 'package:trek/features/auth/presentation/bloc/auth_bloc.dart';
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUserEntity = UserEntity(
    id: '1',
    firstName: 'John',
    lastName: 'Doe',
    email: tEmail,
    phone: '1234567890',
    role: 'customer',
  );

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when login succeeds',
      build: () {
        when(mockAuthRepository.login(tEmail, tPassword))
            .thenAnswer((_) async => Right(tUserEntity));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(tEmail, tPassword)),
      expect: () => [AuthLoading(), Authenticated(tUserEntity)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockAuthRepository.login(tEmail, tPassword))
            .thenAnswer((_) async => const Left('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(tEmail, tPassword)),
      expect: () => [AuthLoading(), AuthError('Invalid credentials')],
    );
  });

  group('RegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when register succeeds',
      build: () {
        when(mockAuthRepository.register(tUserEntity, tPassword))
            .thenAnswer((_) async => Right(tUserEntity));
        return authBloc;
      },
      act: (bloc) => bloc.add(RegisterRequested(tUserEntity, tPassword)),
      expect: () => [AuthLoading(), Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when register fails',
      build: () {
        when(mockAuthRepository.register(tUserEntity, tPassword))
            .thenAnswer((_) async => const Left('User already exists'));
        return authBloc;
      },
      act: (bloc) => bloc.add(RegisterRequested(tUserEntity, tPassword)),
      expect: () => [AuthLoading(), AuthError('User already exists')],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when logout succeeds',
      build: () {
        when(mockAuthRepository.logout())
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [AuthLoading(), Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when logout fails',
      build: () {
        when(mockAuthRepository.logout())
            .thenAnswer((_) async => const Left('Logout failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [AuthLoading(), AuthError('Logout failed')],
    );
  });
} 