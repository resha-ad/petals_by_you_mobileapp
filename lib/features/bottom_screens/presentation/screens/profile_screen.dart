import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/core/utils/snackbar_utils.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
import 'package:sprint1_project/features/auth/presentation/screens/login_screen.dart';
import 'package:sprint1_project/features/auth/presentation/state/auth_state.dart';
import 'package:sprint1_project/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sprint1_project/features/orders/presentation/screen/orders_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).getCurrentUser();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _populateFields(AuthEntity user) {
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _usernameController.text = user.username;
    _phoneController.text = user.phone ?? '';
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) return;
    }
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (file != null) setState(() => _selectedImage = File(file.path));
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFFAD1457),
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFFAD1457),
              ),
              title: const Text('Choose from Gallery'),
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
    final user = ref.read(authViewModelProvider).user;
    if (user == null) return;
    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{};
    if (_firstNameController.text.trim().isNotEmpty) {
      data['firstName'] = _firstNameController.text.trim();
    }
    if (_lastNameController.text.trim().isNotEmpty) {
      data['lastName'] = _lastNameController.text.trim();
    }
    if (_usernameController.text.trim().isNotEmpty) {
      data['username'] = _usernameController.text.trim();
    }
    if (_phoneController.text.trim().isNotEmpty) {
      data['phone'] = _phoneController.text.trim();
    }
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text.length < 8) {
        showSnackbar(
          context,
          'Password must be at least 8 characters',
          color: Colors.red.shade600,
        );
        setState(() => _isSubmitting = false);
        return;
      }
      data['password'] = _passwordController.text;
    }

    await ref
        .read(authViewModelProvider.notifier)
        .updateProfile(data: data, image: _selectedImage);

    if (mounted) {
      final state = ref.read(authViewModelProvider);
      if (state.status == AuthStatus.authenticated) {
        setState(() => _selectedImage = null);
        _passwordController.clear();
        showSnackbar(
          context,
          'Profile updated successfully',
          color: Colors.green.shade600,
        );
      } else if (state.status == AuthStatus.error) {
        showSnackbar(
          context,
          state.errorMessage ?? 'Update failed',
          color: Colors.red.shade600,
        );
        ref.read(authViewModelProvider.notifier).clearError();
      }
    }
    setState(() => _isSubmitting = false);
  }

  ImageProvider _buildProfileImage(AuthEntity? user) {
    if (_selectedImage != null) return FileImage(_selectedImage!);
    final img = user?.imageUrl;
    if (img != null && img.isNotEmpty) {
      return NetworkImage(ApiEndpoints.fullImageUrl(img));
    }
    return const AssetImage('assets/images/default-profile.png');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    if (user != null &&
        authState.status != AuthStatus.loading &&
        _firstNameController.text.isEmpty) {
      _populateFields(user);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: authState.status == AuthStatus.loading && user == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFAD1457)),
            )
          : RefreshIndicator(
              color: const Color(0xFFAD1457),
              onRefresh: () =>
                  ref.read(authViewModelProvider.notifier).getCurrentUser(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ── Avatar ───────────────────────────────────────────────
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundImage: _buildProfileImage(user),
                          backgroundColor: const Color(0xFFF8BBD0),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 2,
                          child: GestureDetector(
                            onTap: _showImageOptions,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFAD1457),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (user != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (user.role == 'admin')
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8BBD0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFAD1457),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],

                    const SizedBox(height: 24),

                    // ── Orders shortcut card ─────────────────────────────────
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F4EE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                color: Color(0xFF1B4332),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Orders',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Track and view your order history',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF9E9E9E),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Personal info form ───────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  'First Name',
                                  _firstNameController,
                                  icon: Icons.person_outline,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  'Last Name',
                                  _lastNameController,
                                  icon: Icons.person_outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            'Username',
                            _usernameController,
                            icon: Icons.alternate_email_outlined,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            'Phone',
                            _phoneController,
                            icon: Icons.phone_outlined,
                            keyboard: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Security card ────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Leave blank to keep current password',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              labelStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F7F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Save button ──────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAD1457),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Logout ───────────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
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
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFAD1457), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
