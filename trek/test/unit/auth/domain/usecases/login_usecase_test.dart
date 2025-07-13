import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:trek/features/auth/domain/entities/user_entity.dart';
import 'package:trek/features/auth/domain/repositories/auth_repository.dart';
import 'package:trek/features/auth/domain/usecases/login_usecase.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUserEntity = UserEntity(
    id: '1',
    firstName: 'John',
    lastName: 'Doe',
    email: 'test@example.com',
    phone: '1234567890',
    role: 'customer',
  );

  test(
    'should get UserEntity from the repository when login is successful',
    () async {
      // arrange
      when(mockAuthRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => Right(tUserEntity));

      // act
      final result = await useCase(tEmail, tPassword);

      // assert
      expect(result, Right(tUserEntity));
      verify(mockAuthRepository.login(tEmail, tPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return failure when repository returns failure',
    () async {
      // arrange
      const failureMessage = 'Invalid credentials';
      when(mockAuthRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Left(failureMessage));

      // act
      final result = await useCase(tEmail, tPassword);

      // assert
      expect(result, const Left(failureMessage));
      verify(mockAuthRepository.login(tEmail, tPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
} 