import 'package:flutter/material.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF1B4332);
const _kAccent = Color(0xFFD4A853);
const _kTextMid = Color(0xFF5C5C5C);
const _kTextLight = Color(0xFF9E9E9E);

class ItemFilterBar extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedSort;
  final void Function(String? category, String? sort) onFilterChanged;

  const ItemFilterBar({
    super.key,
    this.selectedCategory,
    this.selectedSort,
    required this.onFilterChanged,
  });

  @override
  State<ItemFilterBar> createState() => _ItemFilterBarState();
}

class _ItemFilterBarState extends State<ItemFilterBar> {
  // ── Correct backend categories ─────────────────────────────────────────────
  static const List<({String value, String label})> _categories = [
    (value: '', label: 'All'),
    (value: 'bouquets', label: 'Bouquets'),
    (value: 'flowers', label: 'Flowers'),
    (value: 'arrangements', label: 'Arrangements'),
    (value: 'gifts', label: 'Gift Sets'),
    (value: 'others', label: 'Others'),
  ];

  static const Map<String, String> _sortOptions = {
    'Newest': 'createdAt:desc',
    'Price ↑': 'price:asc',
    'Price ↓': 'price:desc',
  };

  late String _selectedCategory;
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory ?? '';
    _selectedSort = widget.selectedSort;
  }

  @override
  void didUpdateWidget(ItemFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      _selectedCategory = widget.selectedCategory ?? '';
    }
    if (widget.selectedSort != oldWidget.selectedSort) {
      _selectedSort = widget.selectedSort;
    }
  }

  void _onCategoryTap(String value) {
    setState(() => _selectedCategory = value);
    widget.onFilterChanged(value.isEmpty ? null : value, _selectedSort);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Category chips ──────────────────────────────────────────────────
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final isSelected = cat.value == _selectedCategory;
              return GestureDetector(
                onTap: () => _onCategoryTap(cat.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _kPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _kPrimary : const Color(0xFFE0D9CF),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _kPrimary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : _kTextMid,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // ── Sort chips ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Sort:',
                style: TextStyle(
                  fontSize: 13,
                  color: _kTextLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sortOptions.entries.map((entry) {
                      final isActive = _selectedSort == entry.value;
                      return GestureDetector(
                        onTap: () {
                          setState(
                            () => _selectedSort = isActive ? null : entry.value,
                          );
                          widget.onFilterChanged(
                            _selectedCategory.isEmpty
                                ? null
                                : _selectedCategory,
                            isActive ? null : entry.value,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFFFF3D4)
                                : const Color(0xFFF5F2EE),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive ? _kAccent : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isActive
                                  ? const Color(0xFF7A5E00)
                                  : _kTextMid,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
