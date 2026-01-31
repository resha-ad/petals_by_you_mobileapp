import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/auth/data/repositories/auth_repository.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UpdateProfileUsecase(authRepository: authRepository);
});

class UpdateProfileParams extends Equatable {
  final String id;
  final Map<String, dynamic> data;
  final File? image; // Keep this

  const UpdateProfileParams({required this.id, required this.data, this.image});

  @override
  List<Object?> get props => [id, data, image];
}

class UpdateProfileUsecase
    implements UseCaseWithParams<AuthEntity, UpdateProfileParams> {
  final IAuthRepository _authRepository;

  UpdateProfileUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateProfileParams params) {
    return _authRepository.updateUser(params.id, params.data, params.image);
  }
}
