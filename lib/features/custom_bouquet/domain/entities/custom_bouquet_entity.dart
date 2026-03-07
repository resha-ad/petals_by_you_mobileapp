import 'package:equatable/equatable.dart';

class BouquetFlower extends Equatable {
  final String flowerId;
  final String name;
  final int count;
  final double pricePerStem;

  const BouquetFlower({
    required this.flowerId,
    required this.name,
    required this.count,
    required this.pricePerStem,
  });

  double get subtotal => count * pricePerStem;

  BouquetFlower copyWith({int? count}) => BouquetFlower(
    flowerId: flowerId,
    name: name,
    count: count ?? this.count,
    pricePerStem: pricePerStem,
  );

  Map<String, dynamic> toJson() => {
    'flowerId': flowerId,
    'name': name,
    'count': count,
    'pricePerStem': pricePerStem,
  };

  @override
  List<Object?> get props => [flowerId, count];
}

class BouquetWrapping extends Equatable {
  final String id;
  final String name;
  final double price;
  final String color; // hex for display
  final String darkColor; // hex for text/border

  const BouquetWrapping({
    required this.id,
    required this.name,
    required this.price,
    required this.color,
    required this.darkColor,
  });

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};

  @override
  List<Object?> get props => [id];
}

class CustomBouquetEntity extends Equatable {
  final List<BouquetFlower> flowers;
  final BouquetWrapping? wrapping;
  final String note;
  final String recipientName;

  const CustomBouquetEntity({
    this.flowers = const [],
    this.wrapping,
    this.note = '',
    this.recipientName = '',
  });

  int get totalStems => flowers.fold(0, (sum, f) => sum + f.count);

  double get totalPrice =>
      flowers.fold(0.0, (sum, f) => sum + f.subtotal) + (wrapping?.price ?? 0);

  CustomBouquetEntity copyWith({
    List<BouquetFlower>? flowers,
    BouquetWrapping? wrapping,
    bool clearWrapping = false,
    String? note,
    String? recipientName,
  }) => CustomBouquetEntity(
    flowers: flowers ?? this.flowers,
    wrapping: clearWrapping ? null : (wrapping ?? this.wrapping),
    note: note ?? this.note,
    recipientName: recipientName ?? this.recipientName,
  );

  Map<String, dynamic> toPayload() => {
    'flowers': flowers.map((f) => f.toJson()).toList(),
    'wrapping': wrapping?.toJson(),
    'note': note.trim(),
    'recipientName': recipientName.trim(),
    'totalPrice': totalPrice,
  };

  @override
  List<Object?> get props => [flowers, wrapping, note, recipientName];
}
