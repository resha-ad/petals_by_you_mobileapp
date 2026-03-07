import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/features/items/presentation/state/item_state.dart';
import 'package:sprint1_project/features/items/presentation/view_model/item_view_model.dart';
import 'package:sprint1_project/features/items/presentation/widgets/item_card_widget.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF1B4332);
const _kAccent = Color(0xFFD4A853);
const _kBackground = Color(0xFFF9F6F0);
const _kSurface = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextMid = Color(0xFF5C5C5C);
const _kTextLight = Color(0xFF9E9E9E);

// ── Categories ────────────────────────────────────────────────────────────────
const _kCategories = [
  (value: '', label: 'All', icon: Icons.apps_rounded),
  (value: 'bouquets', label: 'Bouquets', icon: Icons.local_florist_rounded),
  (value: 'flowers', label: 'Flowers', icon: Icons.eco_rounded),
  (value: 'arrangements', label: 'Arrangements', icon: Icons.spa_rounded),
  (value: 'gifts', label: 'Gift Sets', icon: Icons.card_giftcard_rounded),
  (value: 'others', label: 'Others', icon: Icons.more_horiz_rounded),
];

// ── Sort options ──────────────────────────────────────────────────────────────
const _kSortOptions = [
  (label: 'Newest', value: 'createdAt:desc', icon: Icons.schedule_rounded),
  (label: 'Price: Low', value: 'price:asc', icon: Icons.arrow_upward_rounded),
  (
    label: 'Price: High',
    value: 'price:desc',
    icon: Icons.arrow_downward_rounded,
  ),
];

// Dedicated provider — search state is isolated from home
final searchItemsProvider = NotifierProvider<ItemViewModel, ItemState>(
  ItemViewModel.new,
);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  bool _isSearchFocused = false;

  // We always want to keep alive so category/sort state survives tab switches
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _focusNode.addListener(
      () => setState(() => _isSearchFocused = _focusNode.hasFocus),
    );

    // Load all products immediately on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchItemsProvider.notifier).loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      // Immediately reload all products when query is cleared
      ref
          .read(searchItemsProvider.notifier)
          .loadItems(
            category: ref.read(searchItemsProvider).activeCategory,
            sort: ref.read(searchItemsProvider).activeSort,
          );
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      ref.read(searchItemsProvider.notifier).search(value);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchItemsProvider.notifier).loadMore();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    ref
        .read(searchItemsProvider.notifier)
        .loadItems(
          category: ref.read(searchItemsProvider).activeCategory,
          sort: ref.read(searchItemsProvider).activeSort,
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(searchItemsProvider);
    final isOffline = state.isFromCache;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _kBackground,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header with search bar ─────────────────────────────────────
            _SearchHeader(
              controller: _searchController,
              focusNode: _focusNode,
              isFocused: _isSearchFocused,
              hasText: _searchController.text.isNotEmpty,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
            ),

            // ── Category filter row ────────────────────────────────────────
            _CategoryBar(
              selected: state.activeCategory,
              onTap: (val) => ref
                  .read(searchItemsProvider.notifier)
                  .applyFilter(
                    category: val.isEmpty ? null : val,
                    sort: state.activeSort,
                  ),
            ),

            // ── Sort chips ─────────────────────────────────────────────────
            _SortBar(
              selected: state.activeSort,
              onTap: (val) => ref
                  .read(searchItemsProvider.notifier)
                  .applyFilter(
                    category: state.activeCategory,
                    sort: state.activeSort == val ? null : val,
                  ),
            ),

            // ── Result count / offline banner ──────────────────────────────
            if (state.items.isNotEmpty || isOffline)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    if (state.items.isNotEmpty)
                      Text(
                        '${state.items.length} item${state.items.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _kTextLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (isOffline) ...[
                      const Spacer(),
                      Row(
                        children: const [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 12,
                            color: Color(0xFFB08800),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7A5E00),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // ── Product grid ───────────────────────────────────────────────
            Expanded(child: _buildBody(state, isOffline)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ItemState state, bool isOffline) {
    if (state.status == ItemStatus.loading && state.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2),
      );
    }

    if (state.status == ItemStatus.error && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 32,
                color: Color(0xFF52B788),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load products',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.errorMessage ?? 'Check your connection',
              style: const TextStyle(fontSize: 13, color: _kTextLight),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 32,
                color: Color(0xFF52B788),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try different keywords or filters',
              style: TextStyle(fontSize: 13, color: _kTextLight),
            ),
          ],
        ),
      );
    }

    // 2-column grid
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount:
          state.items.length + (state.status == ItemStatus.loadingMore ? 2 : 0),
      itemBuilder: (_, i) {
        if (i >= state.items.length) {
          return const _CardSkeleton();
        }
        return ItemCard(
          item: state.items[i],
          isOffline: isOffline,
          onFavoriteTap: () {},
        );
      },
    );
  }
}

// ── Search header ─────────────────────────────────────────────────────────────
class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool hasText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.hasText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      decoration: const BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (Navigator.canPop(context))
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              const Text(
                'Shop',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Browse our full collection',
            style: TextStyle(fontSize: 13, color: Color(0xFFADD8B4)),
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: _kAccent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                color: _kTextDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search flowers, bouquets...',
                hintStyle: const TextStyle(color: _kTextLight, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _kPrimary,
                  size: 20,
                ),
                suffixIcon: hasText
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: _kTextLight,
                          size: 18,
                        ),
                        onPressed: onClear,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category filter bar ───────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final String? selected;
  final void Function(String val) onTap;
  const _CategoryBar({this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: _kCategories.length,
        itemBuilder: (_, i) {
          final cat = _kCategories[i];
          final isActive = (selected ?? '') == cat.value;
          return GestureDetector(
            onTap: () => onTap(cat.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _kPrimary : _kSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? _kPrimary : const Color(0xFFE0D9CF),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 14,
                    color: isActive ? Colors.white : _kTextMid,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : _kTextMid,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Sort bar ──────────────────────────────────────────────────────────────────
class _SortBar extends StatelessWidget {
  final String? selected;
  final void Function(String val) onTap;
  const _SortBar({this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemCount: _kSortOptions.length,
        itemBuilder: (_, i) {
          final opt = _kSortOptions[i];
          final isActive = selected == opt.value;
          return GestureDetector(
            onTap: () => onTap(opt.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFFFF3D4)
                    : const Color(0xFFF0EDE8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? _kAccent : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    opt.icon,
                    size: 13,
                    color: isActive ? const Color(0xFF7A5E00) : _kTextMid,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? const Color(0xFF7A5E00) : _kTextMid,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Loading skeleton card ─────────────────────────────────────────────────────
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 11,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 11,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 14,
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
