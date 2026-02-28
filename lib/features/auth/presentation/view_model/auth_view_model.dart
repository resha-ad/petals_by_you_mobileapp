import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/login_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/register_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:sprint1_project/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final ForgotPasswordUsecase _forgotPasswordUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _forgotPasswordUsecase = ref.read(forgotPasswordUsecaseProvider);
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
    return const AuthState();
  }

  // ─── Register ──────────────────────────────────────────────────────────────
  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _registerUsecase(
      RegisterParams(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  // ─── Login ─────────────────────────────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _loginUsecase(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  // ─── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _logoutUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  // ─── Get Current User ──────────────────────────────────────────────────────
  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _getCurrentUserUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  // ─── Update Profile ────────────────────────────────────────────────────────
  Future<void> updateProfile({
    required Map<String, dynamic> data,
    File? image,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _updateProfileUsecase(
      UpdateProfileParams(data: data, image: image),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (updatedUser) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
      ),
    );
  }

  // ─── Forgot Password ───────────────────────────────────────────────────────
  Future<void> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _forgotPasswordUsecase(
      ForgotPasswordParams(email: email),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.forgotPasswordSent),
    );
  }

  // ─── Reset Password ────────────────────────────────────────────────────────
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _resetPasswordUsecase(
      ResetPasswordParams(token: token, newPassword: newPassword),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.passwordReset),
    );
  }

  void clearError() {
    state = state.copyWith(status: AuthStatus.initial, errorMessage: null);
  }
}
