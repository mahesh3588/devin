class LedgerEntry {
  LedgerEntry({
    required this.ledgerId,
    required this.itemId,
    required this.date,
    required this.transactionType,
    required this.quantity,
    required this.balanceAfter,
  });

  final String ledgerId;
  final String itemId;
  final DateTime date;
  final String transactionType;
  final int quantity;
  final int balanceAfter;

  factory LedgerEntry.fromCsv(List<dynamic> row) {
    return LedgerEntry(
      ledgerId: row[0].toString(),
      itemId: row[1].toString(),
      date: DateTime.tryParse(row[2].toString()) ?? DateTime.now(),
      transactionType: row[3].toString(),
      quantity: int.tryParse(row[4].toString()) ?? 0,
      balanceAfter: int.tryParse(row[5].toString()) ?? 0,
    );
  }

  List<dynamic> toCsv() => [
        ledgerId,
        itemId,
        date.toIso8601String(),
        transactionType,
        quantity,
        balanceAfter,
      ];
}
