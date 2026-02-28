// import 'package:dartz/dartz.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:sprint1_project/core/error/failures.dart';
// import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
// import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';
// import 'package:sprint1_project/features/auth/domain/usecases/register_usecase.dart';

// class MockAuthRepository extends Mock implements IAuthRepository {}

// void main() {
//   setUpAll(() {
//     // Register a dummy/fallback instance of AuthEntity
//     registerFallbackValue(
//       const AuthEntity(
//         authId: 'fallback',
//         fullName: 'Fallback User',
//         email: 'fallback@example.com',
//         password: 'fallback123',
//       ),
//     );
//   });

//   late RegisterUsecase usecase;
//   late MockAuthRepository mockRepository;

//   setUp(() {
//     mockRepository = MockAuthRepository();
//     usecase = RegisterUsecase(authRepository: mockRepository);
//   });

//   const tFullName = 'Test User';
//   const tEmail = 'test@example.com';
//   const tPassword = 'password123';

//   group('RegisterUsecase', () {
//     test('should return true when registration is successful', () async {
//       // Arrange
//       when(
//         () => mockRepository.register(any()),
//       ).thenAnswer((_) async => const Right(true));

//       // Act
//       final result = await usecase(
//         const RegisterParams(
//           fullName: tFullName,
//           email: tEmail,
//           password: tPassword,
//         ),
//       );

//       // Assert
//       expect(result, const Right(true));
//       verify(() => mockRepository.register(any())).called(1);
//       verifyNoMoreInteractions(mockRepository);
//     });

//     test('should return failure when registration fails', () async {
//       // Arrange
//       const failure = ApiFailure(message: 'Email already exists');
//       when(
//         () => mockRepository.register(any()),
//       ).thenAnswer((_) async => const Left(failure));

//       // Act
//       final result = await usecase(
//         const RegisterParams(
//           fullName: tFullName,
//           email: tEmail,
//           password: tPassword,
//         ),
//       );

//       // Assert
//       expect(result, const Left(failure));
//       verify(() => mockRepository.register(any())).called(1);
//       verifyNoMoreInteractions(mockRepository);
//     });

//     test('should pass correct entity to repository', () async {
//       // Arrange
//       when(
//         () => mockRepository.register(any()),
//       ).thenAnswer((_) async => const Right(true));

//       // Act
//       await usecase(
//         const RegisterParams(
//           fullName: tFullName,
//           email: tEmail,
//           password: tPassword,
//         ),
//       );

//       // Assert - capture and verify the entity passed
//       final captured =
//           verify(() => mockRepository.register(captureAny())).captured.single
//               as AuthEntity;

//       expect(captured.fullName, tFullName);
//       expect(captured.email, tEmail);
//       expect(captured.password, tPassword);
//     });
//   });

//   group('RegisterParams', () {
//     test('should have correct props', () {
//       const params = RegisterParams(
//         fullName: tFullName,
//         email: tEmail,
//         password: tPassword,
//       );
//       expect(params.props, [tFullName, tEmail, tPassword]);
//     });

//     test('two params with same values should be equal', () {
//       const params1 = RegisterParams(
//         fullName: tFullName,
//         email: tEmail,
//         password: tPassword,
//       );
//       const params2 = RegisterParams(
//         fullName: tFullName,
//         email: tEmail,
//         password: tPassword,
//       );
//       expect(params1, params2);
//     });

//     test('two params with different values should not be equal', () {
//       const params1 = RegisterParams(
//         fullName: tFullName,
//         email: tEmail,
//         password: tPassword,
//       );
//       const params2 = RegisterParams(
//         fullName: 'Different',
//         email: tEmail,
//         password: tPassword,
//       );
//       expect(params1, isNot(params2));
//     });
//   });
// }
