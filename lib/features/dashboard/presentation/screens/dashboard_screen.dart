import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/favorites_screen.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/home_screen.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/profile_screen.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/search_screen.dart';
import 'package:sprint1_project/features/cart/presentation/screen/cart_screen.dart';
import 'package:sprint1_project/features/cart/presentation/view_model/cart_view_model.dart';

const _kPrimary = Color(0xFF1B4332);
const _kBackground = Color(0xFFF9F6F0);

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.search_rounded, label: 'Search'),
    _NavItem(icon: Icons.favorite_rounded, label: 'Wishlist'),
    _NavItem(icon: Icons.shopping_bag_rounded, label: 'Cart'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final cartCount = cartState.itemCount;

    return Scaffold(
      backgroundColor: _kBackground,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        items: _navItems,
        cartBadgeCount: cartCount,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final int cartBadgeCount;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.selectedIndex,
    required this.items,
    required this.cartBadgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: bottomPad + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (i) {
          final isSelected = i == selectedIndex;
          final item = items[i];

          // Centre tab (Wishlist/index 2) — raised pill
          if (i == 2) {
            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? _kPrimary : const Color(0xFFF0EDE8),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _kPrimary.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: isSelected ? Colors.white : const Color(0xFFB0A898),
                ),
              ),
            );
          }

          // Cart tab (index 3) — show badge
          if (i == 3) {
            return GestureDetector(
              onTap: () => onTap(i),
              child: SizedBox(
                width: 52,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: isSelected ? 36 : 0,
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: _kPrimary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isSelected
                              ? _kPrimary
                              : const Color(0xFFB0A898),
                        ),
                        if (cartBadgeCount > 0)
                          Positioned(
                            top: -6,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4A853),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                cartBadgeCount > 99 ? '99+' : '$cartBadgeCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected ? _kPrimary : const Color(0xFFB0A898),
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            );
          }

          return GestureDetector(
            onTap: () => onTap(i),
            child: SizedBox(
              width: 52,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: isSelected ? 36 : 0,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Icon(
                    item.icon,
                    size: 22,
                    color: isSelected ? _kPrimary : const Color(0xFFB0A898),
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected ? _kPrimary : const Color(0xFFB0A898),
                    ),
                    child: Text(item.label),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
