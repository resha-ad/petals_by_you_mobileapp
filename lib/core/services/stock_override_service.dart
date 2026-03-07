import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

/// Tracks stock deductions made by orders placed on THIS device.
/// Applied on top of whatever the server returns so the UI always
/// shows accurate local stock — no backend changes required.
final stockOverrideServiceProvider = Provider<StockOverrideService>((ref) {
  return StockOverrideService();
});

class StockOverrideService {
  static const _kKey = 'local_stock_deductions';

  // itemId → total quantity deducted from local orders
  final Map<String, int> _deductions = {};
  bool _loaded = false;

  // ── Load persisted deductions from disk (called lazily) ──────────────────
  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      if (raw != null) {
        final map = json.decode(raw) as Map<String, dynamic>;
        map.forEach((k, v) => _deductions[k] = (v as num).toInt());
      }
    } catch (_) {}
    _loaded = true;
  }

  // ── Record that an order consumed [quantity] of [itemId] ─────────────────
  Future<void> recordDeduction(String itemId, int quantity) async {
    await load();
    _deductions[itemId] = (_deductions[itemId] ?? 0) + quantity;
    await _persist();
  }

  // ── Apply override to a single item ──────────────────────────────────────
  ItemEntity applyToItem(ItemEntity item) {
    final deduction = _deductions[item.id] ?? 0;
    if (deduction == 0) return item;

    final adjustedStock = (item.stock - deduction).clamp(0, 999999);
    return ItemEntity(
      id: item.id,
      name: item.name,
      slug: item.slug,
      description: item.description,
      price: item.price,
      discountPrice: item.discountPrice,
      category: item.category,
      images: item.images,
      isFeatured: item.isFeatured,
      // Mark unavailable when stock hits zero locally
      isAvailable: adjustedStock > 0 ? item.isAvailable : false,
      stock: adjustedStock,
      rating: item.rating,
      numReviews: item.numReviews,
      preparationTime: item.preparationTime,
      deliveryType: item.deliveryType,
    );
  }

  // ── Apply overrides to a whole list ──────────────────────────────────────
  List<ItemEntity> applyToList(List<ItemEntity> items) {
    if (_deductions.isEmpty) return items;
    return items.map(applyToItem).toList();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kKey, json.encode(_deductions));
    } catch (_) {}
  }
}
