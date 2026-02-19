import 'item.dart';

class InvoiceLine {
  InvoiceLine({required this.item, required this.quantity});

  final Item item;
  final int quantity;

  double get total => item.price * quantity;
}

class InvoiceData {
  InvoiceData({
    required this.invoiceNumber,
    required this.businessName,
    required this.customerName,
    required this.date,
    required this.lines,
    required this.taxRate,
  });

  final String invoiceNumber;
  final String businessName;
  final String customerName;
  final DateTime date;
  final List<InvoiceLine> lines;
  final double taxRate;

  double get subtotal => lines.fold(0, (sum, line) => sum + line.total);
  double get tax => subtotal * taxRate;
  double get total => subtotal + tax;
}
