import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/core/providers/sensor_providers.dart';
import 'package:sprint1_project/core/sensors/gyroscope_sensor.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';

class ProfileHeaderWidget extends ConsumerWidget {
  final AuthEntity? user;
  final File? selectedImage;
  final VoidCallback onAvatarTap;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.selectedImage,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tilt = ref.watch(gyroTiltProvider).asData?.value ?? GyroTilt.zero;
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, top + 20, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A0032), Color(0xFFAD1457), Color(0xFFD81B60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        children: [
          // ── Avatar with gyro parallax layers ──────────────────────────────
          GestureDetector(
            onTap: onAvatarTap,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring — shifts most (farthest layer)
                  Transform.translate(
                    offset: Offset(tilt.x * 18, tilt.y * 18),
                    child: Container(
                      width: 116,
                      height: 116,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                  ),
                  // Mid ring
                  Transform.translate(
                    offset: Offset(tilt.x * 10, tilt.y * 10),
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  // Avatar — shifts least (closest layer)
                  Transform.translate(
                    offset: Offset(tilt.x * 5, tilt.y * 5),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(tilt.x * 8, tilt.y * 8 + 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundImage: _buildImage(user),
                        backgroundColor: const Color(0xFFF8BBD0),
                      ),
                    ),
                  ),
                  // Camera badge
                  Positioned(
                    bottom: 2,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFAD1457),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Color(0xFFAD1457),
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Name ──────────────────────────────────────────────────────────
          Text(
            user?.fullName ?? '—',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.72),
            ),
          ),
          const SizedBox(height: 10),

          // ── Badges ────────────────────────────────────────────────────────
          Wrap(
            spacing: 8,
            children: [
              if (user?.role == 'admin')
                _Badge(
                  label: '★ Admin',
                  bg: const Color(0xFFFFD700).withOpacity(0.25),
                  fg: const Color(0xFFFFD700),
                ),
              if (user?.username.isNotEmpty ?? false)
                _Badge(
                  label: '@${user!.username}',
                  bg: Colors.white.withOpacity(0.15),
                  fg: Colors.white,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Gyro hint ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.screen_rotation_rounded,
                color: Colors.white.withOpacity(0.45),
                size: 12,
              ),
              const SizedBox(width: 5),
              Text(
                'Tilt your phone to see the parallax effect',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ImageProvider _buildImage(AuthEntity? user) {
    if (selectedImage != null) return FileImage(selectedImage!);
    final img = user?.imageUrl;
    if (img != null && img.isNotEmpty) {
      return NetworkImage(ApiEndpoints.fullImageUrl(img));
    }
    return const AssetImage('assets/images/default-profile.png');
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
