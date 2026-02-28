// import 'dart:io';

// import 'package:dartz/dartz.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:sprint1_project/core/error/failures.dart';
// import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
// import 'package:sprint1_project/features/auth/domain/usecases/get_current_user_usecase.dart';
// import 'package:sprint1_project/features/auth/domain/usecases/login_usecase.dart';
// import 'package:sprint1_project/features/auth/domain/usecases/logout_usecase.dart';
// import 'package:sprint1_project/features/auth/domain/usecases/register_usecase.dart';
// import 'package:sprint1_project/features/auth/domain/usecases/update_profile_usecase.dart';
// import 'package:sprint1_project/features/auth/domain/usecases/upload_profile_picture_usecase.dart';
// import 'package:sprint1_project/features/auth/presentation/state/auth_state.dart';
// import 'package:sprint1_project/features/auth/presentation/view_model/auth_view_model.dart';

// class MockRegisterUsecase extends Mock implements RegisterUsecase {}

// class MockLoginUsecase extends Mock implements LoginUsecase {}

// class MockLogoutUsecase extends Mock implements LogoutUsecase {}

// class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

// class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

// class MockUploadProfilePictureUsecase extends Mock
//     implements UploadProfilePictureUsecase {}

// void main() {
//   late MockRegisterUsecase mockRegister;
//   late MockLoginUsecase mockLogin;
//   late MockLogoutUsecase mockLogout;
//   late MockGetCurrentUserUsecase mockGetCurrentUser;
//   late MockUpdateProfileUsecase mockUpdateProfile;
//   late MockUploadProfilePictureUsecase mockUploadPicture;

//   late ProviderContainer container;

//   setUpAll(() {
//     registerFallbackValue(
//       const RegisterParams(
//         fullName: 'fallback',
//         email: 'fallback@email.com',
//         password: 'fallback',
//       ),
//     );
//     registerFallbackValue(
//       const LoginParams(email: 'fallback@email.com', password: 'fallback'),
//     );
//     registerFallbackValue(const UpdateProfileParams(id: 'fallback', data: {}));
//     registerFallbackValue(File('fallback.jpg'));
//   });

//   setUp(() {
//     mockRegister = MockRegisterUsecase();
//     mockLogin = MockLoginUsecase();
//     mockLogout = MockLogoutUsecase();
//     mockGetCurrentUser = MockGetCurrentUserUsecase();
//     mockUpdateProfile = MockUpdateProfileUsecase();
//     mockUploadPicture = MockUploadProfilePictureUsecase();

//     container = ProviderContainer(
//       overrides: [
//         registerUsecaseProvider.overrideWith((ref) => mockRegister),
//         loginUsecaseProvider.overrideWith((ref) => mockLogin),
//         logoutUsecaseProvider.overrideWith((ref) => mockLogout),
//         getCurrentUserUsecaseProvider.overrideWith((ref) => mockGetCurrentUser),
//         updateProfileUsecaseProvider.overrideWith((ref) => mockUpdateProfile),
//         uploadProfilePictureUsecaseProvider.overrideWith(
//           (ref) => mockUploadPicture,
//         ),
//       ],
//     );
//   });

//   tearDown(() {
//     container.dispose();
//   });

//   const tUser = AuthEntity(
//     authId: '1',
//     fullName: 'Test User',
//     email: 'test@example.com',
//   );

//   group('AuthViewModel', () {
//     group('initial state', () {
//       test('should have initial state', () {
//         final state = container.read(authViewModelProvider);
//         expect(state.status, AuthStatus.initial);
//         expect(state.user, isNull);
//         expect(state.errorMessage, isNull);
//       });
//     });

//     group('login', () {
//       test('should emit authenticated when login succeeds', () async {
//         when(() => mockLogin(any())).thenAnswer((_) async => Right(tUser));

//         final notifier = container.read(authViewModelProvider.notifier);
//         await notifier.login(email: 'test@example.com', password: '123');

//         final state = container.read(authViewModelProvider);
//         expect(state.status, AuthStatus.authenticated);
//         expect(state.user, tUser);
//       });

//       test('should emit error when login fails', () async {
//         const failure = ApiFailure(message: 'Invalid credentials');
//         when(() => mockLogin(any())).thenAnswer((_) async => Left(failure));

//         final notifier = container.read(authViewModelProvider.notifier);
//         await notifier.login(email: 'test@example.com', password: 'wrong');

//         final state = container.read(authViewModelProvider);
//         expect(state.status, AuthStatus.error);
//         expect(state.errorMessage, 'Invalid credentials');
//       });
//     });

//     group('logout', () {
//       test('should emit unauthenticated when logout succeeds', () async {
//         when(() => mockLogout()).thenAnswer((_) async => const Right(true));

//         final notifier = container.read(authViewModelProvider.notifier);
//         await notifier.logout();

//         final state = container.read(authViewModelProvider);
//         expect(state.status, AuthStatus.unauthenticated);
//         expect(state.user, isNull);
//       });
//     });

//     group('getCurrentUser', () {
//       test('should emit authenticated with user when found', () async {
//         when(() => mockGetCurrentUser()).thenAnswer((_) async => Right(tUser));

//         final notifier = container.read(authViewModelProvider.notifier);
//         await notifier.getCurrentUser();

//         final state = container.read(authViewModelProvider);
//         expect(state.status, AuthStatus.authenticated);
//         expect(state.user, tUser);
//       });
//     });
//   });
// }
