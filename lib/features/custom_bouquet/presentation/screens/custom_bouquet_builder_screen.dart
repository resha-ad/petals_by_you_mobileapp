import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';
import 'package:sprint1_project/features/custom_bouquet/presentation/state/custom_bouquet_state.dart';
import 'package:sprint1_project/features/custom_bouquet/presentation/view_model/custom_bouquet_view_model.dart';

// ── Static flower catalog ─────────────────────────────────────────────────────
const _flowers = [
  _FlowerData(
    'rose',
    'Rose',
    'Classic & romantic',
    120,
    Color(0xFFFCE4EC),
    '🌹',
  ),
  _FlowerData(
    'tulip',
    'Tulip',
    'Elegant & graceful',
    90,
    Color(0xFFFFCDD2),
    '🌷',
  ),
  _FlowerData(
    'sunflower',
    'Sunflower',
    'Bright & cheerful',
    80,
    Color(0xFFFFF9C4),
    '🌻',
  ),
  _FlowerData('lily', 'Lily', 'Pure & serene', 110, Color(0xFFEDE7F6), '🪷'),
  _FlowerData('daisy', 'Daisy', 'Sweet & playful', 70, Color(0xFFF9FBE7), '🌼'),
  _FlowerData(
    'orchid',
    'Orchid',
    'Exotic & mysterious',
    180,
    Color(0xFFF3E5F5),
    '💜',
  ),
  _FlowerData(
    'peony',
    'Peony',
    'Lush & romantic',
    150,
    Color(0xFFFCE4EC),
    '🌸',
  ),
  _FlowerData(
    'lavender',
    'Lavender',
    'Calm & fragrant',
    85,
    Color(0xFFEDE7F6),
    '💜',
  ),
];

const _wrappings = [
  _WrappingData(
    'kraft',
    'Kraft Paper',
    'Rustic & natural',
    50,
    Color(0xFFEFEBE9),
    Color(0xFF5D4037),
  ),
  _WrappingData(
    'silk',
    'Silk Ribbon',
    'Elegant & luxurious',
    120,
    Color(0xFFFCE4EC),
    Color(0xFF880E4F),
  ),
  _WrappingData(
    'burlap',
    'Burlap & Twine',
    'Earthy & charming',
    70,
    Color(0xFFF1F8E9),
    Color(0xFF1B5E20),
  ),
  _WrappingData(
    'velvet',
    'Velvet Wrap',
    'Rich & opulent',
    150,
    Color(0xFFEDE7F6),
    Color(0xFF4A148C),
  ),
  _WrappingData(
    'lace',
    'Lace & Pearl',
    'Romantic & delicate',
    130,
    Color(0xFFFDF0FF),
    Color(0xFF6A1B9A),
  ),
  _WrappingData(
    'minimal',
    'Minimal White',
    'Clean & modern',
    40,
    Color(0xFFF5F5F5),
    Color(0xFF37474F),
  ),
];

const _kBackground = Color(0xFFF9F6F0);
const _kSurface = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextLight = Color(0xFF9E9E9E);
const _kRose = Color(0xFF6B4E4E);

class CustomBouquetBuilderScreen extends ConsumerStatefulWidget {
  const CustomBouquetBuilderScreen({super.key});

  @override
  ConsumerState<CustomBouquetBuilderScreen> createState() =>
      _CustomBouquetBuilderScreenState();
}

class _CustomBouquetBuilderScreenState
    extends ConsumerState<CustomBouquetBuilderScreen> {
  @override
  void initState() {
    super.initState();
    // Reset to fresh state each time we open the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customBouquetViewModelProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customBouquetViewModelProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kBackground,
        body: Column(
          children: [
            _BuilderHeader(
              step: state.step,
              onBack: () => Navigator.pop(context),
            ),
            _StepIndicator(current: state.step),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(state.step),
                    child: _buildStep(state),
                  ),
                ),
              ),
            ),
            if (state.step < 5)
              _NavBar(
                step: state.step,
                canProceed: state.canProceed,
                onBack: () => ref
                    .read(customBouquetViewModelProvider.notifier)
                    .prevStep(),
                onNext: () => ref
                    .read(customBouquetViewModelProvider.notifier)
                    .nextStep(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(CustomBouquetState state) {
    final vm = ref.read(customBouquetViewModelProvider.notifier);
    switch (state.step) {
      case 1:
        return _StepFlowers(
          bouquet: state.bouquet,
          onToggle: (f) => vm.toggleFlower(f),
        );
      case 2:
        return _StepCount(bouquet: state.bouquet, onChange: vm.setFlowerCount);
      case 3:
        return _StepWrapping(
          bouquet: state.bouquet,
          onSelect: vm.selectWrapping,
        );
      case 4:
        return _StepNote(
          bouquet: state.bouquet,
          onNoteChange: vm.setNote,
          onNameChange: vm.setRecipientName,
        );
      case 5:
        return _StepReview(
          state: state,
          onEdit: (s) => vm.goToStep(s),
          onSubmit: () => _handleSubmit(context),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final vm = ref.read(customBouquetViewModelProvider.notifier);
    final success = await vm.submit();
    if (!mounted) return;
    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌸', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              const Text(
                'Added to Cart!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _kRose,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your custom bouquet is in your cart.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9A7A7A)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kRose,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // close dialog only
                    // Reset the form — user navigates away via bottom nav
                    ref.read(customBouquetViewModelProvider.notifier).reset();
                    // Only pop the screen if it was pushed
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Great!',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final err = ref.read(customBouquetViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Something went wrong. Please try again.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STEP COMPONENTS
// ═══════════════════════════════════════════════════════════════════

class _StepFlowers extends StatelessWidget {
  final CustomBouquetEntity bouquet;
  final void Function(BouquetFlower) onToggle;
  const _StepFlowers({required this.bouquet, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final selectedIds = bouquet.flowers.map((f) => f.flowerId).toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle(
          'Choose Your Flowers',
          'Select one or more blooms to mix and match.',
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.55,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _flowers.length,
          itemBuilder: (_, i) {
            final f = _flowers[i];
            final selected = selectedIds.contains(f.id);
            return GestureDetector(
              onTap: () => onToggle(
                BouquetFlower(
                  flowerId: f.id,
                  name: f.name,
                  count: 3,
                  pricePerStem: f.price.toDouble(),
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected ? f.color.withValues(alpha: 0.5) : _kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? _kRose : const Color(0xFFEEE8DE),
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(f.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            f.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kTextDark,
                            ),
                          ),
                          Text(
                            'Rs. ${f.price}/stem',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _kTextLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: _kRose,
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StepCount extends StatelessWidget {
  final CustomBouquetEntity bouquet;
  final void Function(String flowerId, int count) onChange;
  const _StepCount({required this.bouquet, required this.onChange});

  @override
  Widget build(BuildContext context) {
    if (bouquet.flowers.isEmpty) {
      return const Center(
        child: Text('Please go back and select at least one flower.'),
      );
    }
    final total = bouquet.totalStems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle('How Many Stems?', '$total stems total'),
        const SizedBox(height: 16),
        ...bouquet.flowers.map((sel) {
          final fd = _flowers.firstWhere(
            (f) => f.id == sel.flowerId,
            orElse: () => _flowers[0],
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEE8DE)),
            ),
            child: Row(
              children: [
                Text(fd.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sel.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _kTextDark,
                        ),
                      ),
                      Text(
                        'Rs. ${sel.pricePerStem.toInt()}/stem · Rs. ${sel.subtotal.toInt()} total',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _kTextLight,
                        ),
                      ),
                    ],
                  ),
                ),
                _CounterControl(
                  value: sel.count,
                  min: 1,
                  max: 20,
                  onChanged: (v) => onChange(sel.flowerId, v),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _StepWrapping extends StatelessWidget {
  final CustomBouquetEntity bouquet;
  final void Function(BouquetWrapping) onSelect;
  const _StepWrapping({required this.bouquet, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle(
          'Pick Your Wrapping',
          'The finishing touch that makes it a gift.',
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _wrappings.length,
          itemBuilder: (_, i) {
            final w = _wrappings[i];
            final selected = bouquet.wrapping?.id == w.id;
            return GestureDetector(
              onTap: () => onSelect(
                BouquetWrapping(
                  id: w.id,
                  name: w.name,
                  price: w.price.toDouble(),
                  color: '#F3E6E6',
                  darkColor: '#6B4E4E',
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected ? w.color.withValues(alpha: 0.6) : _kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? _kRose : const Color(0xFFEEE8DE),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: w.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: w.darkColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: _kRose,
                            size: 18,
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _kTextDark,
                          ),
                        ),
                        Text(
                          '+ Rs. ${w.price}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _kTextLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StepNote extends StatefulWidget {
  final CustomBouquetEntity bouquet;
  final void Function(String) onNoteChange;
  final void Function(String) onNameChange;
  const _StepNote({
    required this.bouquet,
    required this.onNoteChange,
    required this.onNameChange,
  });

  @override
  State<_StepNote> createState() => _StepNoteState();
}

class _StepNoteState extends State<_StepNote> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.bouquet.recipientName);
    _noteCtrl = TextEditingController(text: widget.bouquet.note);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle(
          'Add a Personal Note',
          'Both fields are optional — but they make all the difference.',
        ),
        const SizedBox(height: 20),
        _InputField(
          controller: _nameCtrl,
          label: "Recipient's Name",
          hint: 'e.g. My Dearest Priya...',
          icon: Icons.person_outline,
          onChanged: widget.onNameChange,
        ),
        const SizedBox(height: 14),
        _InputField(
          controller: _noteCtrl,
          label: 'Your Message',
          hint: 'Write something from the heart...',
          icon: Icons.mail_outline_rounded,
          maxLines: 5,
          maxLength: 200,
          onChanged: widget.onNoteChange,
        ),
        const SizedBox(height: 12),
        const Text(
          'Quick starters:',
          style: TextStyle(fontSize: 12, color: _kTextLight),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                    'You make every day bloom 🌸',
                    'With all my love ❤️',
                    'Happy Birthday! 🎂',
                    'Thank you for everything',
                    'Thinking of you',
                  ]
                  .map(
                    (t) => GestureDetector(
                      onTap: () {
                        _noteCtrl.text = t;
                        widget.onNoteChange(t);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E6E6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(fontSize: 12, color: _kRose),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class _StepReview extends StatelessWidget {
  final CustomBouquetState state;
  final void Function(int) onEdit;
  final VoidCallback onSubmit;
  const _StepReview({
    required this.state,
    required this.onEdit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final b = state.bouquet;
    final submitting = state.status == CustomBouquetStatus.submitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle('Review Your Bouquet', 'Everything look perfect?'),
        const SizedBox(height: 20),

        // Flowers
        _ReviewCard(
          title: 'Flowers',
          onEdit: () => onEdit(1),
          child: Column(
            children: b.flowers.map((f) {
              final fd = _flowers.firstWhere(
                (x) => x.id == f.flowerId,
                orElse: () => _flowers[0],
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(fd.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${f.name} × ${f.count}',
                        style: const TextStyle(fontSize: 13, color: _kTextDark),
                      ),
                    ),
                    Text(
                      'Rs. ${f.subtotal.toInt()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kRose,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),

        // Wrapping
        if (b.wrapping != null)
          _ReviewCard(
            title: 'Wrapping',
            onEdit: () => onEdit(3),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3E6E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    size: 14,
                    color: _kRose,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    b.wrapping!.name,
                    style: const TextStyle(fontSize: 13, color: _kTextDark),
                  ),
                ),
                Text(
                  '+ Rs. ${b.wrapping!.price.toInt()}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kRose,
                  ),
                ),
              ],
            ),
          ),

        // Note
        if (b.recipientName.isNotEmpty || b.note.isNotEmpty) ...[
          const SizedBox(height: 10),
          _ReviewCard(
            title: 'Personal Note',
            onEdit: () => onEdit(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (b.recipientName.isNotEmpty)
                  Text(
                    'To: ${b.recipientName}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: _kRose,
                    ),
                  ),
                if (b.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '"${b.note}"',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF7A6060),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 10),

        // Total
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7EDEB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kRose,
                ),
              ),
              Text(
                'Rs. ${b.totalPrice.toInt()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _kRose,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: submitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kRose,
              disabledBackgroundColor: _kRose.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Add to Cart →',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _BuilderHeader extends StatelessWidget {
  final int step;
  final VoidCallback onBack;
  const _BuilderHeader({required this.step, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    const labels = ['Flowers', 'Count', 'Wrapping', 'Message', 'Review'];

    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 14, 20, 18),
      decoration: const BoxDecoration(
        color: _kRose,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Build Your Bouquet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Step $step of 5 · ${labels[step - 1]}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFEED5D5),
                  ),
                ),
              ],
            ),
          ),
          const Text('🌸', style: TextStyle(fontSize: 28)),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(5, (i) {
          final s = i + 1;
          final done = s < current;
          final active = s == current;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done || active ? _kRose : const Color(0xFFEEE8DE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 4) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int step;
  final bool canProceed;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _NavBar({
    required this.step,
    required this.canProceed,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: _kSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (step > 1)
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kRose,
                side: const BorderSide(color: Color(0xFFE8B4B8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            )
          else
            const Spacer(),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: canProceed ? onNext : null,
            icon: Text(
              step == 4 ? 'Review' : 'Continue',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            label: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kRose,
              disabledBackgroundColor: const Color(0xFFE8D0D0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StepTitle(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _kRose,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: _kTextLight),
        ),
      ],
    );
  }
}

class _CounterControl extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;
  const _CounterControl({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CBtn(
          icon: Icons.remove_rounded,
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _kTextDark,
            ),
          ),
        ),
        _CBtn(
          icon: Icons.add_rounded,
          onTap: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _CBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFFF3E6E6)
              : const Color(0xFFF0EDE8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? _kRose : _kTextLight,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onEdit;
  const _ReviewCard({
    required this.title,
    required this.child,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEE8DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Color(0xFFC08080),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kRose,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final int? maxLength;
  final void Function(String) onChanged;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: _kTextDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: _kTextLight, fontSize: 13),
        hintStyle: const TextStyle(color: _kTextLight, fontSize: 13),
        prefixIcon: Icon(icon, color: _kTextLight, size: 18),
        filled: true,
        fillColor: const Color(0xFFF7F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kRose, width: 1.5),
        ),
        counterStyle: const TextStyle(fontSize: 11, color: _kTextLight),
      ),
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────
class _FlowerData {
  final String id;
  final String name;
  final String tagline;
  final int price;
  final Color color;
  final String emoji;
  const _FlowerData(
    this.id,
    this.name,
    this.tagline,
    this.price,
    this.color,
    this.emoji,
  );
}

class _WrappingData {
  final String id;
  final String name;
  final String tagline;
  final int price;
  final Color color;
  final Color darkColor;
  const _WrappingData(
    this.id,
    this.name,
    this.tagline,
    this.price,
    this.color,
    this.darkColor,
  );
}
