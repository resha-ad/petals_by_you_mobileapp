// import 'dart:io';

// import 'package:dartz/dartz.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sprint1_project/core/error/failures.dart';
// import 'package:sprint1_project/core/usecases/app_usecase.dart';
// import 'package:sprint1_project/features/auth/data/repositories/auth_repository.dart';
// import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';

// final uploadProfilePictureUsecaseProvider =
//     Provider<UploadProfilePictureUsecase>((ref) {
//       return UploadProfilePictureUsecase(
//         repository: ref.read(authRepositoryProvider),
//       );
//     });

// class UploadProfilePictureUsecase implements UseCaseWithParams<String, File> {
//   final IAuthRepository repository;

//   UploadProfilePictureUsecase({required this.repository});

//   @override
//   Future<Either<Failure, String>> call(File image) {
//     return repository.uploadProfilePicture(image);
//   }
// }
