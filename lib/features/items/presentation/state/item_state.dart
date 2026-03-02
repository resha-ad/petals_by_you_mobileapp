import 'package:equatable/equatable.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

enum ItemStatus { initial, loading, loadingMore, loaded, error }

class ItemState extends Equatable {
  final ItemStatus status;
  final List<ItemEntity> items;
  final ItemEntity? selectedItem;
  final String? errorMessage;

  // Pagination
  final int currentPage;
  final bool hasMore;

  // Active filters
  final String? activeCategory;
  final String? activeSearch;
  final String? activeSort;

  /// True when data was read from Hive cache (offline / stale network)
  final bool isFromCache;

  const ItemState({
    this.status = ItemStatus.initial,
    this.items = const [],
    this.selectedItem,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.activeCategory,
    this.activeSearch,
    this.activeSort,
    this.isFromCache = false,
  });

  ItemState copyWith({
    ItemStatus? status,
    List<ItemEntity>? items,
    ItemEntity? selectedItem,
    bool clearSelectedItem = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    int? currentPage,
    bool? hasMore,
    String? activeCategory,
    bool clearActiveCategory = false,
    String? activeSearch,
    bool clearActiveSearch = false,
    String? activeSort,
    bool clearActiveSort = false,
    bool? isFromCache,
  }) {
    return ItemState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedItem: clearSelectedItem
          ? null
          : (selectedItem ?? this.selectedItem),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      activeCategory: clearActiveCategory
          ? null
          : (activeCategory ?? this.activeCategory),
      activeSearch: clearActiveSearch
          ? null
          : (activeSearch ?? this.activeSearch),
      activeSort: clearActiveSort ? null : (activeSort ?? this.activeSort),
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    selectedItem,
    errorMessage,
    currentPage,
    hasMore,
    activeCategory,
    activeSearch,
    activeSort,
    isFromCache,
  ];
}
