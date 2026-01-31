import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
import 'package:sprint1_project/features/auth/presentation/state/auth_state.dart';
import 'package:sprint1_project/features/auth/presentation/view_model/auth_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isLoading = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    // Load current user on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).getCurrentUser();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  Future<void> _pickFromCamera() async {
    if (!await _requestPermission(Permission.camera)) return;
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() => _profileImage = File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _saveProfile() async {
    final authNotifier = ref.read(authViewModelProvider.notifier);
    final user = ref.read(authViewModelProvider).user;

    //Needs to fix here
    if (user == null || user.authId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No user logged in")));
      // print("No user logged in");
      return;
    }
    //FIXXX HERE

    setState(() => _isLoading = true);

    String? newProfilePicName;

    // 1. Upload image if selected
    if (_profileImage != null) {
      final uploadResult = await authNotifier.uploadProfilePicture(
        _profileImage!,
      );

      final uploadSuccess = uploadResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message ?? "Failed to upload image"),
            ),
          );
          return false;
        },
        (filename) {
          newProfilePicName = filename;
          return true;
        },
      );

      if (!uploadSuccess) {
        setState(() => _isLoading = false);
        return; // Stop if upload failed
      }
    }

    // 2. Prepare update data
    final data = {
      'fullName': _fullNameController.text.trim(),
      'username': _usernameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      if (_dob != null) 'dateOfBirth': _dob!.toIso8601String(),
      'preferredDeliveryTime': _deliveryTimeController.text.trim(),
      if (newProfilePicName != null) 'profilePicture': newProfilePicName,
    };

    // 3. Update profile
    final updateResult = await authNotifier.updateProfile(
      id: user.authId!,
      data: data,
      image: null,
    );

    updateResult.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? "Failed to update profile"),
          ),
        );
      },
      (updatedUser) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        // Refresh user data to show latest changes (including new image)
        authNotifier.getCurrentUser();
      },
    );

    setState(() => _isLoading = false);
  }

  ImageProvider _getProfileImage(AuthEntity? user) {
    if (_profileImage != null) return FileImage(_profileImage!);

    final profilePic = user?.profilePicture;
    if (profilePic != null && profilePic != 'default-profile.png') {
      return NetworkImage(
        '${ApiEndpoints.baseUrl}/uploads/profile_pictures/$profilePic',
      );
    }

    return const AssetImage('assets/images/default-profile.png');
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    // Auto-fill fields when user data is available
    if (user != null) {
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      _usernameController.text = user.username ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _addressController.text = user.address ?? '';
      _deliveryTimeController.text = user.preferredDeliveryTime ?? '';
      if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
        try {
          _dob = DateTime.parse(user.dateOfBirth!);
        } catch (_) {
          // Invalid date format - ignore
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: authState.status == AuthStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (user != null) {
                  await ref
                      .read(authViewModelProvider.notifier)
                      .getCurrentUser();
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Image
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _getProfileImage(user),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.pink,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // User fields
                    _buildTextField("Full Name", _fullNameController),
                    _buildTextField("Email", _emailController),
                    _buildTextField("Username", _usernameController),
                    _buildTextField("Phone Number", _phoneController),
                    _buildTextField("Address", _addressController),

                    _buildTextField(
                      "Date of Birth",
                      TextEditingController(
                        text: _dob == null
                            ? ""
                            : "${_dob!.day}/${_dob!.month}/${_dob!.year}",
                      ),
                      readOnly: true,
                      onTap: _selectDOB,
                    ),

                    _buildTextField(
                      "Preferred Delivery Time",
                      _deliveryTimeController,
                    ),

                    const SizedBox(height: 40),

                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Save Changes"),
                      ),

                    const SizedBox(height: 20),

                    OutlinedButton(
                      onPressed: () async {
                        await ref.read(authViewModelProvider.notifier).logout();
                        if (mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/login',
                          ); // adjust if your login route is different
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
