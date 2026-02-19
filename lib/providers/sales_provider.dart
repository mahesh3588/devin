import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/invoice_data.dart';
import '../services/inventory_service.dart';
import '../services/invoice_service.dart';

class SalesProvider extends ChangeNotifier {
  SalesProvider(this._inventoryService, this._invoiceService);

  final InventoryService _inventoryService;
  final InvoiceService _invoiceService;
  final List<InvoiceLine> _lines = [];
  final _uuid = const Uuid();

  double taxRate = 0.1;

  List<InvoiceLine> get lines => List.unmodifiable(_lines);
  double get subtotal => _lines.fold(0, (sum, line) => sum + line.total);
  double get tax => subtotal * taxRate;
  double get total => subtotal + tax;

  void addLine(InvoiceLine line) {
    _lines.add(line);
    notifyListeners();
  }

  void removeLine(int index) {
    _lines.removeAt(index);
    notifyListeners();
  }

  void setTaxRate(double rate) {
    taxRate = rate;
    notifyListeners();
  }

  Future<void> createSale() async {
    await _inventoryService.createSale(lines: _lines, taxRate: taxRate);
  }

  Future<File> generateInvoice({
    required String businessName,
    required String customerName,
  }) async {
    final data = InvoiceData(
      invoiceNumber: 'INV-${_uuid.v4().substring(0, 8)}',
      businessName: businessName,
      customerName: customerName,
      date: DateTime.now(),
      lines: List.of(_lines),
      taxRate: taxRate,
    );
    return _invoiceService.generateInvoice(data);
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
