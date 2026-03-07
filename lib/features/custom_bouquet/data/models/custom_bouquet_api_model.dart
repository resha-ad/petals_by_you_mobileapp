import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';

class CustomBouquetApiModel {
  final String id;
  final List<BouquetFlower> flowers;
  final BouquetWrapping? wrapping;
  final String note;
  final String recipientName;
  final double totalPrice;

  const CustomBouquetApiModel({
    required this.id,
    required this.flowers,
    this.wrapping,
    required this.note,
    required this.recipientName,
    required this.totalPrice,
  });

  factory CustomBouquetApiModel.fromJson(Map<String, dynamic> json) {
    final rawFlowers = json['flowers'] as List<dynamic>? ?? [];
    final rawWrapping = json['wrapping'] as Map<String, dynamic>?;

    return CustomBouquetApiModel(
      id: json['_id']?.toString() ?? '',
      flowers: rawFlowers
          .map(
            (f) => BouquetFlower(
              flowerId: f['flowerId']?.toString() ?? '',
              name: f['name']?.toString() ?? '',
              count: (f['count'] as num?)?.toInt() ?? 1,
              pricePerStem: (f['pricePerStem'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList(),
      wrapping: rawWrapping != null
          ? BouquetWrapping(
              id: rawWrapping['id']?.toString() ?? '',
              name: rawWrapping['name']?.toString() ?? '',
              price: (rawWrapping['price'] as num?)?.toDouble() ?? 0,
              color: '#F3E6E6',
              darkColor: '#6B4E4E',
            )
          : null,
      note: json['note']?.toString() ?? '',
      recipientName: json['recipientName']?.toString() ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}
