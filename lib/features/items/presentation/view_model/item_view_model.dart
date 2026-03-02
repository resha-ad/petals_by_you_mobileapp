import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/features/items/domain/usecases/get_item_by_id_usecase.dart';
import 'package:sprint1_project/features/items/domain/usecases/get_items_usecase.dart';
import 'package:sprint1_project/features/items/presentation/state/item_state.dart';

final itemViewModelProvider = NotifierProvider<ItemViewModel, ItemState>(
  ItemViewModel.new,
);

class ItemViewModel extends Notifier<ItemState> {
  late final GetItemsUsecase _getItemsUsecase;
  late final GetItemByIdUsecase _getItemByIdUsecase;

  static const int _pageSize = 10;

  @override
  ItemState build() {
    _getItemsUsecase = ref.read(getItemsUsecaseProvider);
    _getItemByIdUsecase = ref.read(getItemByIdUsecaseProvider);
    return const ItemState();
  }

  // ── loadItems ─────────────────────────────────────────────────────────────
  Future<void> loadItems({
    String? category,
    String? search,
    String? sort,
  }) async {
    state = state.copyWith(
      status: ItemStatus.loading,
      items: [],
      currentPage: 1,
      hasMore: true,
      isFromCache: false,
      clearErrorMessage: true,
      activeCategory: category,
      clearActiveCategory: category == null,
      activeSearch: search,
      clearActiveSearch: search == null,
      activeSort: sort,
      clearActiveSort: sort == null,
    );

    final result = await _getItemsUsecase(
      GetItemsParams(
        page: 1,
        limit: _pageSize,
        category: category,
        search: search,
        sort: sort,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ItemStatus.error,
        errorMessage: failure.message,
        isFromCache: false,
      ),
      (dataResult) => state = state.copyWith(
        status: ItemStatus.loaded,
        items: dataResult.data,
        currentPage: 1,
        hasMore: dataResult.data.length >= _pageSize,
        // THE KEY FIX: isFromCache now comes from the actual DataResult
        // so when offline it will be true, when online it will be false
        isFromCache: dataResult.fromCache,
        clearErrorMessage: true,
      ),
    );
  }

  // ── loadMore ──────────────────────────────────────────────────────────────
  Future<void> loadMore() async {
    if (state.status == ItemStatus.loadingMore || !state.hasMore) return;
    if (state.isFromCache) return; // can't paginate cached data

    state = state.copyWith(status: ItemStatus.loadingMore);
    final nextPage = state.currentPage + 1;

    final result = await _getItemsUsecase(
      GetItemsParams(
        page: nextPage,
        limit: _pageSize,
        category: state.activeCategory,
        search: state.activeSearch,
        sort: state.activeSort,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ItemStatus.loaded,
        errorMessage: failure.message,
      ),
      (dataResult) {
        if (dataResult.data.isEmpty) {
          state = state.copyWith(status: ItemStatus.loaded, hasMore: false);
        } else {
          state = state.copyWith(
            status: ItemStatus.loaded,
            items: [...state.items, ...dataResult.data],
            currentPage: nextPage,
            hasMore: dataResult.data.length >= _pageSize,
            isFromCache: dataResult.fromCache,
            clearErrorMessage: true,
          );
        }
      },
    );
  }

  // ── applyFilter ───────────────────────────────────────────────────────────
  Future<void> applyFilter({String? category, String? sort}) async {
    await loadItems(category: category, search: state.activeSearch, sort: sort);
  }

  // ── search ────────────────────────────────────────────────────────────────
  Future<void> search(String query) async {
    await loadItems(
      search: query.isNotEmpty ? query : null,
      category: state.activeCategory,
      sort: state.activeSort,
    );
  }

  // ── clearSearch ───────────────────────────────────────────────────────────
  void clearSearch() => state = const ItemState();

  // ── getItemById ───────────────────────────────────────────────────────────
  Future<void> getItemById(String id) async {
    state = state.copyWith(
      status: ItemStatus.loading,
      clearSelectedItem: true,
      clearErrorMessage: true,
    );

    final result = await _getItemByIdUsecase(GetItemByIdParams(itemId: id));

    result.fold(
      (failure) => state = state.copyWith(
        status: ItemStatus.error,
        errorMessage: failure.message,
      ),
      (dataResult) => state = state.copyWith(
        status: ItemStatus.loaded,
        selectedItem: dataResult.data,
        isFromCache: dataResult.fromCache,
      ),
    );
  }

  void clearError() => state = state.copyWith(
    status: ItemStatus.loaded,
    clearErrorMessage: true,
  );

  void resetSearch() => state = const ItemState();
}
