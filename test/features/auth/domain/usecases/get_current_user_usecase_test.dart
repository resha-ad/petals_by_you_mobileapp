// import 'package:dartz/dartz.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:sprint1_project/core/error/failures.dart';
// import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
// import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';
// import 'package:sprint1_project/features/auth/domain/usecases/get_current_user_usecase.dart';

// class MockAuthRepository extends Mock implements IAuthRepository {}

// void main() {
//   late GetCurrentUserUsecase usecase;
//   late MockAuthRepository mockRepository;

//   setUp(() {
//     mockRepository = MockAuthRepository();
//     usecase = GetCurrentUserUsecase(authRepository: mockRepository);
//   });

//   const tUser = AuthEntity(
//     authId: '1',
//     fullName: 'Test User',
//     email: 'test@example.com',
//     username: 'testuser',
//     phoneNumber: '1234567890',
//     profilePicture: 'profile.jpg',
//     address: 'Kathmandu',
//     dateOfBirth: '2000-01-01',
//     preferredDeliveryTime: 'Morning',
//   );

//   group('GetCurrentUserUsecase', () {
//     test(
//       'should return AuthEntity when user is found in local storage',
//       () async {
//         // Arrange
//         when(
//           () => mockRepository.getCurrentUser(),
//         ).thenAnswer((_) async => const Right(tUser));

//         // Act
//         final result = await usecase();

//         // Assert
//         expect(result, const Right(tUser));
//         verify(() => mockRepository.getCurrentUser()).called(1);
//         verifyNoMoreInteractions(mockRepository);
//       },
//     );

//     test(
//       'should return LocalDatabaseFailure when no user is logged in',
//       () async {
//         // Arrange
//         const failure = LocalDatabaseFailure(message: "No user logged in");
//         when(
//           () => mockRepository.getCurrentUser(),
//         ).thenAnswer((_) async => const Left(failure));

//         // Act
//         final result = await usecase();

//         // Assert
//         expect(result, const Left(failure));
//         verify(() => mockRepository.getCurrentUser()).called(1);
//         verifyNoMoreInteractions(mockRepository);
//       },
//     );

//     test('should return failure when local storage throws an error', () async {
//       // Arrange
//       const failure = LocalDatabaseFailure(message: 'Database error');
//       when(
//         () => mockRepository.getCurrentUser(),
//       ).thenAnswer((_) async => const Left(failure));

//       // Act
//       final result = await usecase();

//       // Assert
//       expect(result, const Left(failure));
//       verify(() => mockRepository.getCurrentUser()).called(1);
//     });

//     test('should return user with all fields correctly mapped', () async {
//       // Arrange
//       when(
//         () => mockRepository.getCurrentUser(),
//       ).thenAnswer((_) async => const Right(tUser));

//       // Act
//       final result = await usecase();

//       // Assert
//       result.fold((failure) => fail('Should return user, not failure'), (user) {
//         expect(user.authId, '1');
//         expect(user.fullName, 'Test User');
//         expect(user.email, 'test@example.com');
//         expect(user.username, 'testuser');
//         expect(user.phoneNumber, '1234567890');
//         expect(user.profilePicture, 'profile.jpg');
//         expect(user.address, 'Kathmandu');
//         expect(user.dateOfBirth, '2000-01-01');
//         expect(user.preferredDeliveryTime, 'Morning');
//       });
//     });
//   });
// }
