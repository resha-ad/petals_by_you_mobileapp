import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/utils/snackbar_utils.dart';
import 'package:sprint1_project/features/auth/presentation/state/auth_state.dart';
import 'package:sprint1_project/features/auth/presentation/view_model/auth_view_model.dart';

const _kPink = Color(0xFFAD1457);

class ChangePasswordFormWidget extends ConsumerStatefulWidget {
  const ChangePasswordFormWidget({super.key});

  @override
  ConsumerState<ChangePasswordFormWidget> createState() =>
      _ChangePasswordFormWidgetState();
}

class _ChangePasswordFormWidgetState
    extends ConsumerState<ChangePasswordFormWidget>
    with SingleTickerProviderStateMixin {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isVerifying = false;
  bool _isChanging = false;
  bool _currentVerified = false;
  String? _currentError;

  late final AnimationController _revealCtrl;
  late final Animation<double> _revealAnim;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _revealAnim = CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Step 1: Verify current password via API ─────────────────────────────
  Future<void> _verifyCurrent() async {
    if (_currentCtrl.text.isEmpty) {
      setState(() => _currentError = 'Enter your current password');
      return;
    }
    setState(() {
      _isVerifying = true;
      _currentError = null;
    });

    // Uses POST /login with current user email — no new endpoint needed.
    final verified = await ref
        .read(authViewModelProvider.notifier)
        .verifyCurrentPassword(_currentCtrl.text);

    setState(() {
      _isVerifying = false;
      _currentVerified = verified;
      _currentError = verified ? null : 'Incorrect password — try again';
    });

    if (verified) _revealCtrl.forward();
  }

  // ── Step 2: Change password ─────────────────────────────────────────────
  Future<void> _changePassword() async {
    final newPw = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    if (newPw.length < 8) {
      showSnackbar(
        context,
        'Password must be at least 8 characters',
        color: Colors.red.shade600,
      );
      return;
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(newPw)) {
      showSnackbar(
        context,
        'Must include at least one number',
        color: Colors.red.shade600,
      );
      return;
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(newPw)) {
      showSnackbar(
        context,
        'Must include at least one uppercase letter',
        color: Colors.red.shade600,
      );
      return;
    }
    if (newPw != confirm) {
      showSnackbar(
        context,
        'Passwords do not match',
        color: Colors.red.shade600,
      );
      return;
    }
    if (newPw == _currentCtrl.text) {
      showSnackbar(
        context,
        'New password must differ from current',
        color: Colors.orange.shade700,
      );
      return;
    }

    setState(() => _isChanging = true);

    await ref
        .read(authViewModelProvider.notifier)
        .updateProfile(
          data: {'currentPassword': _currentCtrl.text, 'password': newPw},
        );

    if (!mounted) return;
    final state = ref.read(authViewModelProvider);
    if (state.status == AuthStatus.authenticated) {
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
      _revealCtrl.reverse();
      setState(() {
        _currentVerified = false;
      });
      showSnackbar(
        context,
        '✓ Password changed successfully',
        color: Colors.green.shade600,
      );
    } else {
      showSnackbar(
        context,
        state.errorMessage ?? 'Failed — try again',
        color: Colors.red.shade600,
      );
      ref.read(authViewModelProvider.notifier).clearError();
    }
    setState(() => _isChanging = false);
  }

  @override
  Widget build(BuildContext context) {
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
          // Section title
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
                  Icons.lock_outline_rounded,
                  color: _kPink,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Step 1: Current password ──────────────────────────────────────
          _PwField(
            controller: _currentCtrl,
            label: 'Current Password',
            obscure: _obscureCurrent,
            enabled: !_currentVerified,
            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
            suffixIcon: _currentVerified
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 20,
                  )
                : null,
          ),

          if (_currentError != null) ...[
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                _currentError!,
                style: TextStyle(fontSize: 12, color: Colors.red.shade600),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Verify button
          if (!_currentVerified)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: _isVerifying
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _kPink,
                        ),
                      )
                    : const Icon(Icons.verified_user_outlined, size: 16),
                label: Text(_isVerifying ? 'Verifying...' : 'Verify Password'),
                onPressed: _isVerifying ? null : _verifyCurrent,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kPink,
                  side: const BorderSide(color: _kPink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),

          // ── Step 2: New password fields (animated reveal) ─────────────────
          SizeTransition(
            sizeFactor: _revealAnim,
            child: Column(
              children: [
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 15,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Identity verified — set your new password',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _PwField(
                  controller: _newCtrl,
                  label: 'New Password',
                  hint: 'Min 8 chars · uppercase · number',
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 12),
                _PwField(
                  controller: _confirmCtrl,
                  label: 'Confirm New Password',
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isChanging
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lock_reset_rounded, size: 16),
                    label: Text(
                      _isChanging ? 'Updating...' : 'Update Password',
                    ),
                    onPressed: _isChanging ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Password field ─────────────────────────────────────────────────────────────
class _PwField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscure;
  final bool enabled;
  final VoidCallback onToggle;
  final Widget? suffixIcon;

  const _PwField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.hint,
    this.enabled = true,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.grey.shade400,
          size: 20,
        ),
        suffixIcon:
            suffixIcon ??
            IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade400,
                size: 20,
              ),
              onPressed: onToggle,
            ),
        filled: true,
        fillColor: enabled ? const Color(0xFFF7F3F5) : const Color(0xFFF0EDED),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPink, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
