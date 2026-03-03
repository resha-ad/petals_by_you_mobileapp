import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:sprint1_project/features/orders/presentation/screen/orders_detail_screen.dart';
import 'package:sprint1_project/features/orders/presentation/view_model/orders_view_model.dart';

const _kPrimary = Color(0xFF1B4332);
const _kBackground = Color(0xFFF9F6F0);
const _kSurface = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextMid = Color(0xFF5C5C5C);
const _kTextLight = Color(0xFF9E9E9E);

class PlaceOrderScreen extends ConsumerStatefulWidget {
  final CartEntity cart;
  const PlaceOrderScreen({super.key, required this.cart});

  @override
  ConsumerState<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends ConsumerState<PlaceOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _paymentMethod = 'cash_on_delivery';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final order = await ref
        .read(ordersViewModelProvider.notifier)
        .placeOrder(
          paymentMethod: _paymentMethod,
          deliveryDetails: {
            'recipientName': _nameCtrl.text.trim(),
            'recipientPhone': _phoneCtrl.text.trim(),
            'address': {
              'street': _streetCtrl.text.trim(),
              'city': _cityCtrl.text.trim(),
              'state': _stateCtrl.text.trim(),
              'zip': _zipCtrl.text.trim(),
              'country': 'Nepal',
            },
          },
          notes: _notesCtrl.text.trim().isNotEmpty
              ? _notesCtrl.text.trim()
              : null,
        );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (order != null) {
      // Reload cart (it's been cleared by the backend)
      ref.read(cartViewModelProvider.notifier).loadCart();
      // Navigate to order detail, removing checkout from stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
      );
    } else {
      final error = ref.read(ordersViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to place order'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kBackground,
        body: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _CheckoutHeader(onBack: () => Navigator.pop(context)),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Delivery details ──────────────────────────────────
                    _FormSection(
                      title: 'Delivery Details',
                      children: [
                        _Field(
                          controller: _nameCtrl,
                          label: 'Recipient Name',
                          icon: Icons.person_outline,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _phoneCtrl,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboard: TextInputType.phone,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _streetCtrl,
                          label: 'Street Address',
                          icon: Icons.location_on_outlined,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _Field(
                                controller: _cityCtrl,
                                label: 'City',
                                icon: Icons.location_city_outlined,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _Field(
                                controller: _zipCtrl,
                                label: 'ZIP',
                                icon: Icons.pin_outlined,
                                keyboard: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _stateCtrl,
                          label: 'State / Province (optional)',
                          icon: Icons.map_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Payment method ─────────────────────────────────────
                    _FormSection(
                      title: 'Payment Method',
                      children: [
                        _PaymentOption(
                          label: 'Cash on Delivery',
                          description: 'Pay when your order arrives',
                          icon: Icons.payments_outlined,
                          value: 'cash_on_delivery',
                          groupValue: _paymentMethod,
                          onChanged: (v) => setState(() => _paymentMethod = v!),
                        ),
                        const SizedBox(height: 8),
                        _PaymentOption(
                          label: 'Online Payment',
                          description: 'Pay securely online',
                          icon: Icons.credit_card_outlined,
                          value: 'online',
                          groupValue: _paymentMethod,
                          onChanged: (v) => setState(() => _paymentMethod = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Notes ──────────────────────────────────────────────
                    _FormSection(
                      title: 'Notes (optional)',
                      children: [
                        TextFormField(
                          controller: _notesCtrl,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Any special instructions...',
                            hintStyle: const TextStyle(
                              color: _kTextLight,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F2EE),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Order summary ─────────────────────────────────────
                    _FormSection(
                      title: 'Order Summary',
                      children: [
                        ...widget.cart.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.displayName} × ${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: _kTextMid,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Rs. ${item.subtotal.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _kTextDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(color: Color(0xFFEEE8DE), height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _kTextDark,
                              ),
                            ),
                            Text(
                              'Rs. ${widget.cart.total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _kPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Place order button ─────────────────────────────────
                    GestureDetector(
                      onTap: _isSubmitting ? null : _submit,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: _kPrimary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _kPrimary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Place Order',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────
class _CheckoutHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _CheckoutHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 18, 20, 24),
      decoration: const BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Enter delivery details',
                  style: TextStyle(fontSize: 13, color: Color(0xFFADD8B4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  final String? Function(String?)? validator;
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      style: const TextStyle(fontSize: 13, color: _kTextDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _kTextLight, fontSize: 13),
        prefixIcon: Icon(icon, color: _kTextLight, size: 18),
        filled: true,
        fillColor: const Color(0xFFF5F2EE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  const _PaymentOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F4EE) : const Color(0xFFF5F2EE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _kPrimary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? _kPrimary : _kTextLight, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _kPrimary : _kTextDark,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 11, color: _kTextLight),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: _kPrimary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
