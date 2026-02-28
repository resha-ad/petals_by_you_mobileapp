// import 'dart:io';

// import 'package:dartz/dartz.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:sprint1_project/core/error/failures.dart';
// import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';
// import 'package:sprint1_project/features/auth/domain/usecases/upload_profile_picture_usecase.dart';

// class MockAuthRepository extends Mock implements IAuthRepository {}

// void main() {
//   late UploadProfilePictureUsecase usecase;
//   late MockAuthRepository mockRepository;

//   setUp(() {
//     mockRepository = MockAuthRepository();
//     usecase = UploadProfilePictureUsecase(repository: mockRepository);
//   });

//   final tImage = File('test.jpg');
//   const tFilename = 'pro-pic-123456789.jpg';

//   group('UploadProfilePictureUsecase', () {
//     test('should return filename when upload is successful', () async {
//       // Arrange
//       when(
//         () => mockRepository.uploadProfilePicture(tImage),
//       ).thenAnswer((_) async => const Right(tFilename));

//       // Act
//       final result = await usecase(tImage);

//       // Assert
//       expect(result, const Right(tFilename));
//       verify(() => mockRepository.uploadProfilePicture(tImage)).called(1);
//       verifyNoMoreInteractions(mockRepository);
//     });

//     test('should return failure when upload fails', () async {
//       // Arrange
//       const failure = ApiFailure(message: 'Upload failed');
//       when(
//         () => mockRepository.uploadProfilePicture(tImage),
//       ).thenAnswer((_) async => const Left(failure));

//       // Act
//       final result = await usecase(tImage);

//       // Assert
//       expect(result, const Left(failure));
//       verify(() => mockRepository.uploadProfilePicture(tImage)).called(1);
//       verifyNoMoreInteractions(mockRepository);
//     });
//   });
// }
