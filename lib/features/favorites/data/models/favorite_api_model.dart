import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/items/data/models/item_api_model.dart';

/// Maps a single item inside `data.items[]` from the backend.
/// The backend populates refId with product fields when type == "product".
class FavoriteItemApiModel {
  final String type;
  final String refId; // raw _id string (used for remove)
  final ItemApiModel? refItem; // populated product data (nullable for custom)

  const FavoriteItemApiModel({
    required this.type,
    required this.refId,
    this.refItem,
  });

  factory FavoriteItemApiModel.fromJson(Map<String, dynamic> json) {
    // refId is either a plain string or a populated object
    final rawRef = json['refId'];
    String id;
    ItemApiModel? item;

    if (rawRef is Map<String, dynamic>) {
      // Populated — extract _id and build ItemApiModel
      id = rawRef['_id']?.toString() ?? '';
      item = ItemApiModel.fromJson(rawRef);
    } else {
      id = rawRef?.toString() ?? '';
    }

    return FavoriteItemApiModel(
      type: json['type']?.toString() ?? 'product',
      refId: id,
      refItem: item,
    );
  }

  FavoriteEntity toEntity() =>
      FavoriteEntity(type: type, refId: refId, refItem: refItem?.toEntity());
}

class FavoritesApiModel {
  final String userId;
  final List<FavoriteItemApiModel> items;

  const FavoritesApiModel({required this.userId, required this.items});

  factory FavoritesApiModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return FavoritesApiModel(
      userId: json['userId']?.toString() ?? '',
      items: rawItems
          .map((e) => FavoriteItemApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  FavoritesEntity toEntity() => FavoritesEntity(
    userId: userId,
    items: items.map((i) => i.toEntity()).toList(),
  );
}
