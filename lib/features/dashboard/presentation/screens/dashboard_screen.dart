import 'package:flutter/material.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/customize_screen.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/favorites_screen.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/home_screen.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/profile_screen.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/search_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    CustomizeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Favorites",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.brush), label: "Customize"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
