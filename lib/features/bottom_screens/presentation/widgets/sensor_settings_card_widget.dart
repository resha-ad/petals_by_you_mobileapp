import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/providers/app_theme_provider.dart';
import 'package:sprint1_project/core/providers/sensor_providers.dart';
import 'package:sprint1_project/core/sensors/light_sensor_service.dart';

const _kPink = Color(0xFFAD1457);

class SensorSettingsCard extends ConsumerWidget {
  final bool shakeEnabled;
  final bool privacyEnabled;
  final ValueChanged<bool> onShakeToggle;
  final ValueChanged<bool> onPrivacyToggle;

  const SensorSettingsCard({
    super.key,
    required this.shakeEnabled,
    required this.privacyEnabled,
    required this.onShakeToggle,
    required this.onPrivacyToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePref = ref.watch(appThemeProvider.notifier).pref;
    final lightLevel = ref.watch(lightLevelProvider).asData?.value;
    final isNear = ref.watch(privacyNearProvider).asData?.value ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: _kPink,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Smart Sensors',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '4 features',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 1. Light sensor → Smart theme
          _SensorRow(
            icon: _lightIcon(lightLevel),
            iconBg: _lightColor(lightLevel).withOpacity(0.12),
            iconColor: _lightColor(lightLevel),
            title: 'Smart Theme',
            subtitle: _lightSubtitle(themePref, lightLevel),
            trailing: DropdownButton<ThemePref>(
              value: themePref,
              underline: const SizedBox(),
              isDense: true,
              style: const TextStyle(
                fontSize: 12,
                color: _kPink,
                fontWeight: FontWeight.w600,
              ),
              items: const [
                DropdownMenuItem(value: ThemePref.auto, child: Text('Auto 🌡')),
                DropdownMenuItem(
                  value: ThemePref.light,
                  child: Text('Light ☀️'),
                ),
                DropdownMenuItem(value: ThemePref.dark, child: Text('Dark 🌑')),
                DropdownMenuItem(
                  value: ThemePref.system,
                  child: Text('System'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(appThemeProvider.notifier).setPref(val);
                }
              },
            ),
          ),

          _Divider(),

          // 2. Accelerometer → Shake to refresh
          _SensorRow(
            icon: Icons.vibration_rounded,
            iconBg: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF1565C0),
            title: 'Shake to Refresh',
            subtitle: shakeEnabled
                ? 'Shake phone to reload your profile'
                : 'Tap to enable shake detection',
            trailing: Switch.adaptive(
              value: shakeEnabled,
              onChanged: onShakeToggle,
              activeColor: _kPink,
            ),
          ),

          _Divider(),

          // 3. Gyroscope → Parallax (always on)
          _SensorRow(
            icon: Icons.rotate_90_degrees_ccw_rounded,
            iconBg: const Color(0xFFF3E5F5),
            iconColor: const Color(0xFF6A1B9A),
            title: 'Profile Avatar Effect',
            subtitle: 'Tilt phone for 3D avatar depth effect',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Always on',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6A1B9A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          _Divider(),

          // 4. Proximity → Privacy mode
          _SensorRow(
            icon: isNear ? Icons.shield_rounded : Icons.shield_outlined,
            iconBg: const Color(0xFFE0F2F1),
            iconColor: const Color(0xFF00695C),
            title: 'Privacy Mode',
            subtitle: isNear
                ? '🔒 Active — sensitive data is hidden'
                : privacyEnabled
                ? 'Pocket/face triggers data masking'
                : 'Enable proximity-based privacy',
            trailing: Switch.adaptive(
              value: privacyEnabled,
              onChanged: onPrivacyToggle,
              activeColor: _kPink,
            ),
          ),
        ],
      ),
    );
  }

  IconData _lightIcon(AmbientLight? level) => switch (level) {
    AmbientLight.dark => Icons.dark_mode_rounded,
    AmbientLight.dim => Icons.wb_twilight_rounded,
    AmbientLight.bright => Icons.wb_sunny_rounded,
    null => Icons.light_mode_outlined,
  };

  Color _lightColor(AmbientLight? level) => switch (level) {
    AmbientLight.dark => const Color(0xFF37474F),
    AmbientLight.dim => Colors.orange.shade700,
    AmbientLight.bright => Colors.amber.shade700,
    null => Colors.orange,
  };

  String _lightSubtitle(ThemePref pref, AmbientLight? level) {
    if (pref != ThemePref.auto) return 'Mode: ${pref.name}';
    if (level == null) return 'Calibrating light sensor...';
    return 'Auto — ambient: ${level.name}';
  }
}

class _SensorRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SensorRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 20, thickness: 1, color: Color(0xFFF5F5F5));
}
