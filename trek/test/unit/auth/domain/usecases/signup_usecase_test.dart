import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:trek/features/auth/domain/entities/user_entity.dart';
import 'package:trek/features/auth/domain/repositories/auth_repository.dart';
import 'package:trek/features/auth/domain/usecases/signup_usecase.dart';

import 'signup_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignupUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignupUseCase(mockAuthRepository);
  });

  const tUserEntity = UserEntity(
    id: '1',
    firstName: 'John',
    lastName: 'Doe',
    email: 'test@example.com',
    phone: '1234567890',
    password: 'password123',
    role: 'customer',
  );

  test(
    'should get UserEntity from the repository when signup is successful',
    () async {
      // arrange
      when(mockAuthRepository.register(tUserEntity, 'password123'))
          .thenAnswer((_) async => Right(tUserEntity));

      // act
      final result = await useCase(tUserEntity, 'password123');

      // assert
      expect(result, Right(tUserEntity));
      verify(mockAuthRepository.register(tUserEntity, 'password123'));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return failure when repository returns failure',
    () async {
      // arrange
      const failureMessage = 'User already exists';
      when(mockAuthRepository.register(tUserEntity, 'password123'))
          .thenAnswer((_) async => const Left(failureMessage));

      // act
      final result = await useCase(tUserEntity, 'password123');

      // assert
      expect(result, const Left(failureMessage));
      verify(mockAuthRepository.register(tUserEntity, 'password123'));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
} 