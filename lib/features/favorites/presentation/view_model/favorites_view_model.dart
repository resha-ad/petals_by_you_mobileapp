import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:sprint1_project/features/favorites/presentation/state/favorites_state.dart';

final favoritesViewModelProvider =
    NotifierProvider<FavoritesViewModel, FavoritesState>(
      FavoritesViewModel.new,
    );

class FavoritesViewModel extends Notifier<FavoritesState> {
  late final GetFavoritesUsecase _getFavorites;
  late final AddFavoriteUsecase _addFavorite;
  late final RemoveFavoriteUsecase _removeFavorite;
  late final INetworkInfo _networkInfo;

  @override
  FavoritesState build() {
    _getFavorites = ref.read(getFavoritesUsecaseProvider);
    _addFavorite = ref.read(addFavoriteUsecaseProvider);
    _removeFavorite = ref.read(removeFavoriteUsecaseProvider);
    _networkInfo = ref.read(networkInfoProvider);
    return const FavoritesState();
  }

  // ── loadFavorites ─────────────────────────────────────────────────────────
  Future<void> loadFavorites() async {
    state = state.copyWith(status: FavoritesStatus.loading, clearError: true);

    // Check connectivity first so we can set isFromCache correctly
    final isOnline = await _networkInfo.isConnected;

    final result = await _getFavorites();
    result.fold(
      (failure) => state = state.copyWith(
        status: FavoritesStatus.error,
        errorMessage: failure.message,
      ),
      (favorites) => state = state.copyWith(
        status: FavoritesStatus.loaded,
        items: favorites.items,
        // Offline → data came from cache; online → fresh from API
        isFromCache: !isOnline,
      ),
    );
  }

  // ── toggleFavorite ────────────────────────────────────────────────────────
  Future<void> toggleFavorite({
    required String refId,
    String type = 'product',
  }) async {
    if (state.isPending(refId)) return;

    final isFav = state.isFavorite(refId);
    state = state.copyWith(pendingIds: {...state.pendingIds, refId});

    final result = isFav
        ? await _removeFavorite(refId)
        : await _addFavorite(AddFavoriteParams(type: type, refId: refId));

    result.fold(
      (failure) => state = state.copyWith(
        pendingIds: state.pendingIds.difference({refId}),
        errorMessage: failure.message,
      ),
      (favorites) => state = state.copyWith(
        status: FavoritesStatus.loaded,
        items: favorites.items,
        pendingIds: state.pendingIds.difference({refId}),
        isFromCache: false,
        clearError: true,
      ),
    );
  }

  // ── addFavorite ───────────────────────────────────────────────────────────
  Future<void> addFavorite({
    required String refId,
    String type = 'product',
  }) async {
    if (state.isPending(refId) || state.isFavorite(refId)) return;
    state = state.copyWith(pendingIds: {...state.pendingIds, refId});

    final result = await _addFavorite(
      AddFavoriteParams(type: type, refId: refId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        pendingIds: state.pendingIds.difference({refId}),
        errorMessage: failure.message,
      ),
      (favorites) => state = state.copyWith(
        status: FavoritesStatus.loaded,
        items: favorites.items,
        pendingIds: state.pendingIds.difference({refId}),
        isFromCache: false,
        clearError: true,
      ),
    );
  }

  // ── removeFavorite ────────────────────────────────────────────────────────
  Future<void> removeFavorite(String refId) async {
    if (state.isPending(refId)) return;
    state = state.copyWith(pendingIds: {...state.pendingIds, refId});

    final result = await _removeFavorite(refId);

    result.fold(
      (failure) => state = state.copyWith(
        pendingIds: state.pendingIds.difference({refId}),
        errorMessage: failure.message,
      ),
      (favorites) => state = state.copyWith(
        status: FavoritesStatus.loaded,
        items: favorites.items,
        pendingIds: state.pendingIds.difference({refId}),
        isFromCache: false,
        clearError: true,
      ),
    );
  }
}
