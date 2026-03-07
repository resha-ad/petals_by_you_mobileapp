import 'package:flutter/material.dart';

/// Central theme-aware color resolver.
/// All screen/widget colors should go through here so dark mode works.
class AppColors {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ── Backgrounds ────────────────────────────────────────────────────────────
  static Color background(BuildContext context) =>
      isDark(context) ? const Color(0xFF0F0F17) : const Color(0xFFF9F6F0);

  static Color surface(BuildContext context) =>
      isDark(context) ? const Color(0xFF1A1A26) : Colors.white;

  static Color surfaceVariant(BuildContext context) =>
      isDark(context) ? const Color(0xFF252535) : const Color(0xFFF5F2EE);

  // ── Text ───────────────────────────────────────────────────────────────────
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? const Color(0xFFF0F0F0) : const Color(0xFF1A1A1A);

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? const Color(0xFFBBBBCC) : const Color(0xFF5C5C5C);

  static Color textHint(BuildContext context) =>
      isDark(context) ? const Color(0xFF777788) : const Color(0xFF9E9E9E);

  // ── Input fields ───────────────────────────────────────────────────────────
  static Color inputFill(BuildContext context) =>
      isDark(context) ? const Color(0xFF252535) : const Color(0xFFF7F3F5);

  static Color inputFillAlt(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E1E2E) : const Color(0xFFF7F7F7);

  // ── Borders / Dividers ─────────────────────────────────────────────────────
  static Color divider(BuildContext context) =>
      isDark(context) ? const Color(0xFF2A2A3A) : const Color(0xFFEEE8DE);

  static Color border(BuildContext context) =>
      isDark(context) ? const Color(0xFF333344) : const Color(0xFFE0D9CF);

  // ── Shadows ────────────────────────────────────────────────────────────────
  static Color shadow(BuildContext context) => isDark(context)
      ? Colors.black.withOpacity(0.4)
      : Colors.black.withOpacity(0.05);

  // ── Offline / Warning banner ───────────────────────────────────────────────
  static Color offlineBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF2A2200) : const Color(0xFFFFF8E7);

  static Color offlineBorder(BuildContext context) =>
      isDark(context) ? const Color(0xFF7A5E00) : const Color(0xFFFFD970);

  // ── Icon containers ────────────────────────────────────────────────────────
  /// Returns a tinted icon background that works on both themes.
  static Color iconContainer(BuildContext context, Color lightBg) =>
      isDark(context) ? lightBg.withOpacity(0.25) : lightBg;

  // ── Common feature colors (same in both themes) ───────────────────────────
  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color accentGold = Color(0xFFD4A853);
  static const Color pink = Color(0xFFAD1457);
  static const Color softGreen = Color(0xFF52B788);
}
