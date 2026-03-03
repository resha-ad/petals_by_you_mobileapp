import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/services/storage/secure_storage_service.dart';
import 'package:sprint1_project/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sprint1_project/features/auth/presentation/state/auth_state.dart';
import 'package:sprint1_project/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:sprint1_project/features/onboarding/presentation/screens/onboarding1_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation + minimum splash duration
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Check if a token exists
    final token = await ref.read(secureStorageProvider).getToken();

    if (!mounted) return;

    if (token != null) {
      // Token found — try to restore session
      await ref.read(authViewModelProvider.notifier).getCurrentUser();
      if (!mounted) return;
      final authState = ref.read(authViewModelProvider);
      if (authState.status == AuthStatus.authenticated) {
        _navigateTo(const DashboardScreen());
        return;
      }
    }

    // No token or auth failed → onboarding
    _navigateTo(const Onboard1());
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, ___) => page,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F8),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Icon
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8BBD0),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFAD1457).withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_florist,
                    size: 60,
                    color: Color(0xFF880E4F),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Petals By You',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your custom bouquet experience',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: const Color(0xFFAD1457).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
