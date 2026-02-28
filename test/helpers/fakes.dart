// import 'dart:io';
// import 'package:dartz/dartz.dart';
// import 'package:sprint1_project/core/error/failures.dart';
// import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
// import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';

// class FakeAuthRepository implements IAuthRepository {
//   @override
//   Future<Either<Failure, bool>> register(AuthEntity user) async {
//     return const Right(true);
//   }

//   @override
//   Future<Either<Failure, AuthEntity>> login(
//     String email,
//     String password,
//   ) async {
//     return Right(AuthEntity(authId: '1', fullName: 'Test User', email: email));
//   }

//   @override
//   Future<Either<Failure, AuthEntity>> getCurrentUser() async {
//     return const Right(
//       AuthEntity(authId: '1', fullName: 'Test User', email: 'test@mail.com'),
//     );
//   }

//   // 🔹 ADD THESE MISSING METHODS

//   @override
//   Future<Either<Failure, bool>> logout() async {
//     return const Right(true);
//   }

//   @override
//   Future<Either<Failure, String>> uploadProfilePicture(File image) async {
//     return const Right('fake_image_url');
//   }

//   @override
//   Future<Either<Failure, AuthEntity>> updateUser(
//     String id,
//     Map<String, dynamic> data,
//     File? image,
//   ) async {
//     return Right(
//       AuthEntity(
//         authId: id,
//         fullName: data['fullName'] ?? 'Updated User',
//         email: data['email'] ?? 'updated@mail.com',
//       ),
//     );
//   }
// }
