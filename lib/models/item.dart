class Item {
  Item({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.price,
    required this.quantity,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String sku;
  final String description;
  final double price;
  final int quantity;
  final DateTime createdAt;

  Item copyWith({
    String? id,
    String? name,
    String? sku,
    String? description,
    double? price,
    int? quantity,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Item.fromCsv(List<dynamic> row) {
    return Item(
      id: row[0].toString(),
      name: row[1].toString(),
      sku: row[2].toString(),
      description: row[3].toString(),
      price: double.tryParse(row[4].toString()) ?? 0,
      quantity: int.tryParse(row[5].toString()) ?? 0,
      createdAt:
          DateTime.tryParse(row[6].toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  List<dynamic> toCsv() => [
        id,
        name,
        sku,
        description,
        price.toStringAsFixed(2),
        quantity,
        createdAt.toIso8601String(),
      ];
}
