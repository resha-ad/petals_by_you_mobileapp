import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final String type; // info | warning | success | promo
  final String targetRole;
  final bool isRead;
  final bool isCleared;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.targetRole,
    required this.isRead,
    required this.isCleared,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? isRead, bool? isCleared}) =>
      NotificationEntity(
        id: id,
        title: title,
        message: message,
        type: type,
        targetRole: targetRole,
        isRead: isRead ?? this.isRead,
        isCleared: isCleared ?? this.isCleared,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, isRead, isCleared];
}
