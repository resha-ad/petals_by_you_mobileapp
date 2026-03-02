import 'package:equatable/equatable.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<FavoriteEntity> items;
  final String? errorMessage;

  /// Set of refIds currently being added/removed (shows per-item loading)
  final Set<String> pendingIds;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.pendingIds = const {},
  });

  bool isFavorite(String refId) => items.any((i) => i.refId == refId);
  bool isPending(String refId) => pendingIds.contains(refId);

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FavoriteEntity>? items,
    String? errorMessage,
    bool clearError = false,
    Set<String>? pendingIds,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingIds: pendingIds ?? this.pendingIds,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, pendingIds];
}
