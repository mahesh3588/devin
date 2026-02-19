class SaleLine {
  SaleLine({
    required this.saleId,
    required this.date,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  final String saleId;
  final DateTime date;
  final String itemId;
  final String itemName;
  final int quantity;
  final double price;
  final double total;

  factory SaleLine.fromCsv(List<dynamic> row) {
    return SaleLine(
      saleId: row[0].toString(),
      date: DateTime.tryParse(row[1].toString()) ?? DateTime.now(),
      itemId: row[2].toString(),
      itemName: row[3].toString(),
      quantity: int.tryParse(row[4].toString()) ?? 0,
      price: double.tryParse(row[5].toString()) ?? 0,
      total: double.tryParse(row[6].toString()) ?? 0,
    );
  }

  List<dynamic> toCsv() => [
        saleId,
        date.toIso8601String(),
        itemId,
        itemName,
        quantity,
        price.toStringAsFixed(2),
        total.toStringAsFixed(2),
      ];
}
