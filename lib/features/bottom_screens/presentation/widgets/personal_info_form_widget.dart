import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';

const _kPink = Color(0xFFAD1457);

class PersonalInfoFormWidget extends StatelessWidget {
  final AuthEntity? user;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController usernameCtrl;
  final TextEditingController phoneCtrl;
  final bool isPrivacyMode;

  const PersonalInfoFormWidget({
    super.key,
    required this.user,
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.usernameCtrl,
    required this.phoneCtrl,
    this.isPrivacyMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.person_outline_rounded,
              label: 'Personal Information',
            ),
            const SizedBox(height: 18),

            // ── First / Last name ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: firstNameCtrl,
                    label: 'First Name',
                    icon: Icons.badge_outlined,
                    validator: _nameValidator('First name'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Field(
                    controller: lastNameCtrl,
                    label: 'Last Name',
                    icon: Icons.badge_outlined,
                    validator: _nameValidator('Last name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Username — local format validation only ────────────────────
            // Uniqueness is validated server-side on save (409 response).
            _Field(
              controller: usernameCtrl,
              label: 'Username',
              icon: Icons.alternate_email_rounded,
              hint: 'Letters, numbers and _ only',
              validator: (v) {
                final val = v?.trim() ?? '';
                if (val.isEmpty) return 'Username is required';
                if (val.length < 3) return 'At least 3 characters';
                if (val.length > 20) return 'Maximum 20 characters';
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(val)) {
                  return 'Only letters, numbers and underscores';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Phone — masked in privacy mode ────────────────────────────
            isPrivacyMode
                ? _MaskedField(
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                  )
                : _Field(
                    controller: phoneCtrl,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboard: TextInputType.phone,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    hint: '98XXXXXXXX',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final digits = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
                      if (digits.length < 7) return 'Enter a valid number';
                      if (digits.length > 15) return 'Number too long';
                      return null;
                    },
                  ),
          ],
        ),
      ),
    );
  }

  String? Function(String?) _nameValidator(String field) => (v) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    if (v.trim().length < 2) return 'Too short';
    if (!RegExp(r"^[a-zA-Z\s'\-]+$").hasMatch(v.trim())) {
      return 'Letters only';
    }
    return null;
  };
}

// ── Masked field ───────────────────────────────────────────────────────────────
class _MaskedField extends StatelessWidget {
  final String label;
  final IconData icon;
  const _MaskedField({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: '••••••••••',
      enabled: false,
      style: const TextStyle(fontSize: 14, letterSpacing: 3),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: _labelStyle,
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        suffixIcon: const Icon(
          Icons.shield_rounded,
          color: Color(0xFF2E7D32),
          size: 18,
        ),
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: _border,
        contentPadding: _contentPad,
      ),
    );
  }
}

// ── Generic field ──────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType keyboard;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboard = TextInputType.text,
    this.formatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: formatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        labelStyle: _labelStyle,
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: const Color(0xFFF7F3F5),
        border: _border,
        focusedBorder: _focusBorder,
        errorBorder: _errorBorder,
        focusedErrorBorder: _errorBorder,
        contentPadding: _contentPad,
      ),
    );
  }
}

// ── Shared decoration ─────────────────────────────────────────────────────────
final _labelStyle = TextStyle(color: Colors.grey.shade500, fontSize: 13);
const _contentPad = EdgeInsets.symmetric(horizontal: 14, vertical: 14);
final _border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide.none,
);
final _focusBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: const BorderSide(color: _kPink, width: 1.5),
);
final _errorBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
);

// ── Card wrapper ──────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
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
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFFCE4EC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _kPink, size: 18),
      ),
      const SizedBox(width: 10),
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D2D2D),
        ),
      ),
    ],
  );
}
