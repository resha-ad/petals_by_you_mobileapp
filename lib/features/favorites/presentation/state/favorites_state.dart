import 'package:equatable/equatable.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<FavoriteEntity> items;
  final String? errorMessage;
  final Set<String> pendingIds;

  /// True when data is being served from the local Hive cache (offline).
  final bool isFromCache;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.pendingIds = const {},
    this.isFromCache = false,
  });

  bool isFavorite(String refId) => items.any((i) => i.refId == refId);
  bool isPending(String refId) => pendingIds.contains(refId);

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FavoriteEntity>? items,
    String? errorMessage,
    bool clearError = false,
    Set<String>? pendingIds,
    bool? isFromCache,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingIds: pendingIds ?? this.pendingIds,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    errorMessage,
    pendingIds,
    isFromCache,
  ];
}
