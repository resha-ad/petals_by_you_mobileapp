import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';
import 'package:sprint1_project/features/items/presentation/state/item_state.dart';
import 'package:sprint1_project/features/items/presentation/view_model/item_view_model.dart';
import 'package:sprint1_project/features/items/presentation/widgets/item_card_widget.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF1B4332);
const _kAccent = Color(0xFFD4A853);
const _kBackground = Color(0xFFF9F6F0);
const _kSurface = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextLight = Color(0xFF9E9E9E);

// Separate provider — home state never touches search state
final homeItemsProvider = NotifierProvider<ItemViewModel, ItemState>(
  ItemViewModel.new,
);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(homeItemsProvider.notifier).loadItems();
      if (mounted) _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeItemsProvider);
    final user = ref.watch(authViewModelProvider).user;
    final isOffline = state.isFromCache;
    final items = state.items;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _kBackground,
        body: RefreshIndicator(
          color: _kPrimary,
          backgroundColor: _kSurface,
          displacement: 60,
          onRefresh: () => ref.read(homeItemsProvider.notifier).loadItems(),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Header ──────────────────────────────────────────────────
                SliverToBoxAdapter(child: _Header(firstName: user?.firstName)),

                // ── Offline banner ───────────────────────────────────────────
                if (isOffline)
                  SliverToBoxAdapter(
                    child: _OfflineBanner(
                      onRetry: () =>
                          ref.read(homeItemsProvider.notifier).loadItems(),
                    ),
                  ),

                // ── Brand / welcome banner ───────────────────────────────────
                const SliverToBoxAdapter(child: _BrandBanner()),

                // ── Loading / error full-screen states ───────────────────────
                if (state.status == ItemStatus.loading && items.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: _kPrimary,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading blooms...',
                            style: TextStyle(color: _kTextLight, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state.status == ItemStatus.error && items.isEmpty)
                  SliverFillRemaining(
                    child: _ErrorState(
                      message: state.errorMessage,
                      onRetry: () =>
                          ref.read(homeItemsProvider.notifier).loadItems(),
                    ),
                  )
                else ...[
                  // ── Sectioned content ──────────────────────────────────────
                  // Featured
                  ..._buildSection(
                    label: 'Featured',
                    icon: Icons.star_rounded,
                    items: items.where((i) => i.isFeatured).take(6).toList(),
                    isOffline: isOffline,
                  ),
                  // New Collection (most recently added — first in list)
                  ..._buildSection(
                    label: 'New Collection',
                    icon: Icons.fiber_new_rounded,
                    items: items.take(6).toList(),
                    isOffline: isOffline,
                  ),
                  // Bouquets
                  ..._buildSection(
                    label: 'Bouquets',
                    icon: Icons.local_florist_rounded,
                    items: items
                        .where((i) => i.category?.toLowerCase() == 'bouquets')
                        .take(6)
                        .toList(),
                    isOffline: isOffline,
                  ),
                  // Arrangements
                  ..._buildSection(
                    label: 'Arrangements',
                    icon: Icons.spa_rounded,
                    items: items
                        .where(
                          (i) => i.category?.toLowerCase() == 'arrangements',
                        )
                        .take(6)
                        .toList(),
                    isOffline: isOffline,
                  ),
                  // Gift Sets
                  ..._buildSection(
                    label: 'Gift Sets',
                    icon: Icons.card_giftcard_rounded,
                    items: items
                        .where((i) => i.category?.toLowerCase() == 'gifts')
                        .take(6)
                        .toList(),
                    isOffline: isOffline,
                  ),
                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSection({
    required String label,
    required IconData icon,
    required List<ItemEntity> items,
    required bool isOffline,
  }) {
    if (items.isEmpty) return [];
    return [
      SliverToBoxAdapter(
        child: _SectionHeader(label: label, icon: icon),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            itemCount: items.length,
            itemBuilder: (_, i) => SizedBox(
              width: 168,
              child: Padding(
                padding: EdgeInsets.only(right: i < items.length - 1 ? 12 : 0),
                child: ItemCard(
                  item: items[i],
                  isOffline: isOffline,
                  onFavoriteTap: () {},
                ),
              ),
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 28)),
    ];
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String? firstName;
  const _Header({this.firstName});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 18, 20, 24),
      decoration: const BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstName != null ? 'Hello, $firstName 👋' : 'Welcome back',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFADD8B4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Petals By You',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Cart
          _IconBtn(icon: Icons.shopping_bag_outlined, onTap: () {}),
          const SizedBox(width: 8),
          // Notifications
          _IconBtn(icon: Icons.notifications_none_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Brand banner ──────────────────────────────────────────────────────────────
class _BrandBanner extends StatelessWidget {
  const _BrandBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        height: 140,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -24,
              top: -24,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kAccent.withOpacity(0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Brand label pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _kAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Handcrafted with love',
                            style: TextStyle(
                              color: _kAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Petals By You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'Fresh blooms for every moment',
                          style: TextStyle(
                            color: Color(0xFFADD8B4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Icon instead of emoji
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_florist_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _kPrimary, size: 17),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kTextDark,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Offline banner ────────────────────────────────────────────────────────────
class _OfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _OfflineBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD970), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 16,
            color: Color(0xFFB08800),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'You\'re offline — showing cached data',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7A5E00),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 12,
                color: _kPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const _ErrorState({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 36,
              color: Color(0xFF52B788),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Couldn't load flowers",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message ?? 'Check your connection and try again',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _kTextLight),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
