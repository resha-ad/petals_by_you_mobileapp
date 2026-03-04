import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sprint1_project/app/themes/app_colors.dart';
import 'package:sprint1_project/core/providers/app_theme_provider.dart';
import 'package:sprint1_project/core/providers/sensor_providers.dart';
import 'package:sprint1_project/core/utils/snackbar_utils.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
import 'package:sprint1_project/features/auth/presentation/screens/login_screen.dart';
import 'package:sprint1_project/features/auth/presentation/state/auth_state.dart';
import 'package:sprint1_project/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/change_password_form_widget.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/personal_info_form_widget.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/profile_header_widget.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/sensor_settings_card_widget.dart';
import 'package:sprint1_project/features/orders/presentation/screen/orders_screen.dart';

const _kPink = Color(0xFFAD1457);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  File? _selectedImage;
  bool _isSubmitting = false;
  bool _fieldsPopulated = false;
  bool _shakeEnabled = true;
  bool _privacyEnabled = true;

  // ── Visible shake refresh indicator ──────────────────────────────────────
  bool _isShakeRefreshing = false;

  StreamSubscription<void>? _shakeSub;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).getCurrentUser();
      _bindShakeSensor();
    });
  }

  void _bindShakeSensor() {
    _shakeSub?.cancel();
    if (!_shakeEnabled) return;
    _shakeSub = ref.read(shakeSensorProvider).onShake.listen((_) async {
      if (_isShakeRefreshing) return; // debounce rapid shakes
      HapticFeedback.mediumImpact();

      // Show the full-screen refresh overlay
      setState(() {
        _isShakeRefreshing = true;
        _fieldsPopulated = false; // force field repopulation with fresh data
      });

      await ref.read(authViewModelProvider.notifier).getCurrentUser();

      // Brief pause so the animation is visible
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        setState(() => _isShakeRefreshing = false);
        showSnackbar(context, '↻ Profile refreshed', color: _kPink);
      }
    });
  }

  @override
  void dispose() {
    _shakeSub?.cancel();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _populateFields(AuthEntity user) {
    _firstNameCtrl.text = user.firstName;
    _lastNameCtrl.text = user.lastName;
    _usernameCtrl.text = user.username;
    _phoneCtrl.text = user.phone ?? '';
    _fieldsPopulated = true;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) return;
    }
    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file != null) setState(() => _selectedImage = File(file.path));
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: _kPink),
              title: Text(
                'Take Photo',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: _kPink),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authViewModelProvider).user;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    await ref
        .read(authViewModelProvider.notifier)
        .updateProfile(
          data: {
            if (_firstNameCtrl.text.trim().isNotEmpty)
              'firstName': _firstNameCtrl.text.trim(),
            if (_lastNameCtrl.text.trim().isNotEmpty)
              'lastName': _lastNameCtrl.text.trim(),
            if (_usernameCtrl.text.trim().isNotEmpty)
              'username': _usernameCtrl.text.trim(),
            if (_phoneCtrl.text.trim().isNotEmpty)
              'phone': _phoneCtrl.text.trim(),
          },
          image: _selectedImage,
        );

    if (!mounted) return;
    final state = ref.read(authViewModelProvider);
    if (state.status == AuthStatus.authenticated) {
      setState(() => _selectedImage = null);
      showSnackbar(context, '✓ Profile updated', color: Colors.green.shade600);
    } else if (state.status == AuthStatus.error) {
      showSnackbar(
        context,
        state.errorMessage ?? 'Update failed',
        color: Colors.red.shade600,
      );
      ref.read(authViewModelProvider.notifier).clearError();
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    // Light sensor → auto theme
    ref.listen(lightLevelProvider, (_, next) {
      next.whenData(
        (level) => ref.read(appThemeProvider.notifier).applyLightSensor(level),
      );
    });

    // Proximity → privacy mode
    final isNear =
        _privacyEnabled &&
        (ref.watch(privacyNearProvider).asData?.value ?? false);

    // Populate once user loaded
    if (user != null &&
        authState.status != AuthStatus.loading &&
        !_fieldsPopulated) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() => _populateFields(user)),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: Stack(
          children: [
            // ── Main scrollable content ─────────────────────────────────────
            authState.status == AuthStatus.loading && user == null
                ? const Center(child: CircularProgressIndicator(color: _kPink))
                : RefreshIndicator(
                    color: _kPink,
                    displacement: 70,
                    onRefresh: () => ref
                        .read(authViewModelProvider.notifier)
                        .getCurrentUser(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: ProfileHeaderWidget(
                            user: user,
                            selectedImage: _selectedImage,
                            onAvatarTap: _showImageOptions,
                          ),
                        ),
                        if (isNear)
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1B5E20,
                                ).withOpacity(0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFF2E7D32,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.shield_rounded,
                                    color: Color(0xFF2E7D32),
                                    size: 15,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '🔒 Privacy Mode — sensitive fields masked',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _OrdersShortcut(),
                              const SizedBox(height: 14),
                              SensorSettingsCard(
                                shakeEnabled: _shakeEnabled,
                                privacyEnabled: _privacyEnabled,
                                onShakeToggle: (val) {
                                  setState(() => _shakeEnabled = val);
                                  _bindShakeSensor();
                                },
                                onPrivacyToggle: (val) =>
                                    setState(() => _privacyEnabled = val),
                              ),
                              const SizedBox(height: 14),
                              PersonalInfoFormWidget(
                                user: user,
                                formKey: _formKey,
                                firstNameCtrl: _firstNameCtrl,
                                lastNameCtrl: _lastNameCtrl,
                                usernameCtrl: _usernameCtrl,
                                phoneCtrl: _phoneCtrl,
                                isPrivacyMode: isNear,
                              ),
                              const SizedBox(height: 14),
                              const ChangePasswordFormWidget(),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  icon: _isSubmitting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.save_rounded,
                                          size: 18,
                                        ),
                                  label: Text(
                                    _isSubmitting
                                        ? 'Saving...'
                                        : 'Save Changes',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: _isSubmitting
                                      ? null
                                      : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _kPink,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.logout_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () async {
                                    await ref
                                        .read(authViewModelProvider.notifier)
                                        .logout();
                                    if (mounted) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                        (_) => false,
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade600,
                                    side: BorderSide(
                                      color: Colors.red.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 110),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),

            // ── Shake refresh overlay — full screen, clearly visible ─────────
            if (_isShakeRefreshing)
              Container(
                color: AppColors.background(context).withOpacity(0.85),
                child: Column(
                  children: [
                    // Top progress bar
                    LinearProgressIndicator(
                      color: _kPink,
                      backgroundColor: _kPink.withOpacity(0.2),
                    ),
                    const Spacer(),
                    // Centre card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 48),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow(context),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.vibration_rounded,
                            color: _kPink,
                            size: 40,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Refreshing Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Shake detected — loading latest data',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint(context),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: _kPink,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrdersShortcut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.iconContainer(
                  context,
                  const Color(0xFFE8F4EE),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF1B4332),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Track and view your order history',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint(context),
            ),
          ],
        ),
      ),
    );
  }
}
