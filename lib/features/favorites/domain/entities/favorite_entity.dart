import 'package:equatable/equatable.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

/// Represents a single favourite entry.
class FavoriteEntity extends Equatable {
  final String type; // "product" | "custom"
  final String refId; // raw ObjectId string (used for removal)
  final ItemEntity? refItem; // populated item when type == "product"

  const FavoriteEntity({required this.type, required this.refId, this.refItem});

  @override
  List<Object?> get props => [type, refId];
}

class FavoritesEntity extends Equatable {
  final String userId;
  final List<FavoriteEntity> items;

  const FavoritesEntity({required this.userId, required this.items});

  @override
  List<Object?> get props => [userId, items];
}
