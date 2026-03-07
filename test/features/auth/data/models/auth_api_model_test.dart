import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/auth/data/models/auth_api_model.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';

void main() {
  group('AuthApiModel', () {
    final tModel = AuthApiModel(
      id: 'user_1',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      username: 'johndoe',
      phone: '+977-9800000000',
      imageUrl: 'https://example.com/photo.jpg',
      role: 'user',
    );

    const tEntity = AuthEntity(
      authId: 'user_1',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      username: 'johndoe',
      phone: '+977-9800000000',
      imageUrl: 'https://example.com/photo.jpg',
      role: 'user',
    );

    // ─── fromJson ──────────────────────────────────────────────────────────
    group('fromJson', () {
      test('should parse all fields from full JSON response', () {
        // Arrange
        final json = {
          '_id': 'user_1',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'username': 'johndoe',
          'phone': '+977-9800000000',
          'imageUrl': 'https://example.com/photo.jpg',
          'role': 'user',
        };

        // Act
        final result = AuthApiModel.fromJson(json);

        // Assert
        expect(result.id, 'user_1');
        expect(result.firstName, 'John');
        expect(result.lastName, 'Doe');
        expect(result.email, 'john@example.com');
        expect(result.username, 'johndoe');
        expect(result.phone, '+977-9800000000');
        expect(result.imageUrl, 'https://example.com/photo.jpg');
        expect(result.role, 'user');
      });

      test('should default role to user when not provided', () {
        // Arrange
        final json = {
          '_id': 'user_1',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'username': 'johndoe',
        };

        // Act
        final result = AuthApiModel.fromJson(json);

        // Assert
        expect(result.role, 'user');
      });

      test('should handle null optional fields', () {
        // Arrange
        final json = {
          '_id': 'user_1',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john@example.com',
          'username': 'johndoe',
        };

        // Act
        final result = AuthApiModel.fromJson(json);

        // Assert
        expect(result.phone, isNull);
        expect(result.imageUrl, isNull);
      });

      test('should handle empty string fields gracefully', () {
        // Arrange
        final json = {
          '_id': '',
          'firstName': '',
          'lastName': '',
          'email': '',
          'username': '',
        };

        // Act
        final result = AuthApiModel.fromJson(json);

        // Assert — empty strings, not null
        expect(result.firstName, '');
        expect(result.lastName, '');
        expect(result.email, '');
        expect(result.username, '');
      });
    });

    // ─── toRegisterJson ────────────────────────────────────────────────────
    group('toRegisterJson', () {
      test('should include required registration fields', () {
        // Arrange
        final model = AuthApiModel(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          username: 'johndoe',
          password: 'password123',
          confirmPassword: 'password123',
        );

        // Act
        final result = model.toRegisterJson();

        // Assert
        expect(result['firstName'], 'John');
        expect(result['lastName'], 'Doe');
        expect(result['email'], 'john@example.com');
        expect(result['username'], 'johndoe');
        expect(result['password'], 'password123');
        expect(result['confirmPassword'], 'password123');
      });

      test('should include phone when not empty', () {
        // Arrange
        final model = AuthApiModel(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          username: 'johndoe',
          phone: '+9779800000000',
        );

        // Act
        final result = model.toRegisterJson();

        // Assert
        expect(result['phone'], '+9779800000000');
      });

      test('should not include phone when null', () {
        // Arrange
        final model = AuthApiModel(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          username: 'johndoe',
        );

        // Act
        final result = model.toRegisterJson();

        // Assert
        expect(result.containsKey('phone'), false);
      });

      test('should not include phone when empty string', () {
        // Arrange
        final model = AuthApiModel(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          username: 'johndoe',
          phone: '',
        );

        // Act
        final result = model.toRegisterJson();

        // Assert
        expect(result.containsKey('phone'), false);
      });
    });

    // ─── toEntity ─────────────────────────────────────────────────────────
    group('toEntity', () {
      test('should convert to AuthEntity correctly', () {
        // Act
        final result = tModel.toEntity();

        // Assert
        expect(result.authId, 'user_1');
        expect(result.firstName, 'John');
        expect(result.lastName, 'Doe');
        expect(result.email, 'john@example.com');
        expect(result.username, 'johndoe');
        expect(result.phone, '+977-9800000000');
        expect(result.imageUrl, 'https://example.com/photo.jpg');
        expect(result.role, 'user');
      });

      test('fullName getter should combine first and last name', () {
        // Act
        final entity = tModel.toEntity();

        // Assert
        expect(entity.fullName, 'John Doe');
      });

      test('should not include password in entity', () {
        // Arrange
        final modelWithPassword = AuthApiModel(
          id: 'user_1',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          username: 'johndoe',
          password: 'secret123',
        );

        // Act
        final entity = modelWithPassword.toEntity();

        // Assert — entity.password comes from AuthEntity not from API
        expect(entity.password, isNull);
      });
    });

    // ─── fromEntity ───────────────────────────────────────────────────────
    group('fromEntity', () {
      test('should convert from AuthEntity correctly', () {
        // Act
        final result = AuthApiModel.fromEntity(tEntity);

        // Assert
        expect(result.id, 'user_1');
        expect(result.firstName, 'John');
        expect(result.lastName, 'Doe');
        expect(result.email, 'john@example.com');
        expect(result.username, 'johndoe');
        expect(result.phone, '+977-9800000000');
        expect(result.imageUrl, 'https://example.com/photo.jpg');
        expect(result.role, 'user');
      });

      test('should carry password from entity when set', () {
        // Arrange
        const entityWithPassword = AuthEntity(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          username: 'johndoe',
          password: 'secret123',
        );

        // Act
        final result = AuthApiModel.fromEntity(entityWithPassword);

        // Assert
        expect(result.password, 'secret123');
      });
    });
  });
}
