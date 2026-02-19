import 'package:uuid/uuid.dart';

import '../models/invoice_data.dart';
import '../models/item.dart';
import '../models/ledger_entry.dart';
import '../models/sale_line.dart';
import 'csv_storage_service.dart';

class InventoryService {
  InventoryService(this._storage);

  final CsvStorageService _storage;
  final _uuid = const Uuid();

  static const _items = 'items.csv';
  static const _sales = 'sales.csv';
  static const _ledger = 'ledger.csv';

  Future<void> initialize() async {
    await _storage.ensureFileExists(fileName: _items, assetPath: 'assets/csv/items.csv');
    await _storage.ensureFileExists(fileName: _sales, assetPath: 'assets/csv/sales.csv');
    await _storage.ensureFileExists(fileName: _ledger, assetPath: 'assets/csv/ledger.csv');
  }

  Future<List<Item>> loadItems() async {
    final rows = await _storage.readCsv(_items);
    if (rows.length <= 1) return [];
    return rows.skip(1).map(Item.fromCsv).toList();
  }

  Future<Item> addItem({
    required String name,
    required String sku,
    required String description,
    required double price,
    required int quantity,
  }) async {
    final items = await loadItems();
    final item = Item(
      id: _uuid.v4(),
      name: name,
      sku: sku,
      description: description,
      price: price,
      quantity: quantity,
      createdAt: DateTime.now(),
    );
    items.add(item);
    await _saveItems(items);
    await _appendLedger(itemId: item.id, transactionType: 'IN', quantity: quantity, balanceAfter: quantity);
    return item;
  }

  Future<void> updateItem(Item updated) async {
    final items = await loadItems();
    final index = items.indexWhere((i) => i.id == updated.id);
    if (index == -1) throw Exception('Item not found');
    items[index] = updated;
    await _saveItems(items);
  }

  Future<void> deleteItem(String itemId) async {
    final items = await loadItems();
    items.removeWhere((i) => i.id == itemId);
    await _saveItems(items);
  }

  Future<void> updateStock({
    required String itemId,
    required int quantity,
    required bool isIn,
  }) async {
    final items = await loadItems();
    final index = items.indexWhere((i) => i.id == itemId);
    if (index == -1) throw Exception('Item not found');
    final item = items[index];

    final newBalance = isIn ? item.quantity + quantity : item.quantity - quantity;
    if (newBalance < 0) throw Exception('Insufficient stock');

    items[index] = item.copyWith(quantity: newBalance);
    await _saveItems(items);
    await _appendLedger(
      itemId: itemId,
      transactionType: isIn ? 'IN' : 'OUT',
      quantity: quantity,
      balanceAfter: newBalance,
    );
  }

  Future<List<SaleLine>> createSale({
    required List<InvoiceLine> lines,
    required double taxRate,
  }) async {
    final saleId = _uuid.v4();
    final now = DateTime.now();
    final created = <SaleLine>[];

    for (final line in lines) {
      await updateStock(itemId: line.item.id, quantity: line.quantity, isIn: false);
      created.add(
        SaleLine(
          saleId: saleId,
          date: now,
          itemId: line.item.id,
          itemName: line.item.name,
          quantity: line.quantity,
          price: line.item.price,
          total: line.total,
        ),
      );
    }

    final allSales = await loadSales();
    allSales.addAll(created);
    await _saveSales(allSales);

    final subtotal = created.fold<double>(0, (sum, e) => sum + e.total);
    final taxAmount = subtotal * taxRate;
    if (taxAmount > 0) {
      allSales.add(
        SaleLine(
          saleId: saleId,
          date: now,
          itemId: 'TAX',
          itemName: 'Tax',
          quantity: 1,
          price: taxAmount,
          total: taxAmount,
        ),
      );
      await _saveSales(allSales);
    }
    return created;
  }

  Future<List<SaleLine>> loadSales() async {
    final rows = await _storage.readCsv(_sales);
    if (rows.length <= 1) return [];
    return rows.skip(1).map(SaleLine.fromCsv).toList();
  }

  Future<List<LedgerEntry>> loadLedger() async {
    final rows = await _storage.readCsv(_ledger);
    if (rows.length <= 1) return [];
    return rows.skip(1).map(LedgerEntry.fromCsv).toList();
  }

  Future<void> _appendLedger({
    required String itemId,
    required String transactionType,
    required int quantity,
    required int balanceAfter,
  }) async {
    final all = await loadLedger();
    all.add(
      LedgerEntry(
        ledgerId: _uuid.v4(),
        itemId: itemId,
        date: DateTime.now(),
        transactionType: transactionType,
        quantity: quantity,
        balanceAfter: balanceAfter,
      ),
    );
    final rows = <List<dynamic>>[
      ['ledger_id', 'item_id', 'date', 'transaction_type', 'quantity', 'balance_after'],
      ...all.map((e) => e.toCsv()),
    ];
    await _storage.writeCsv(_ledger, rows);
  }

  Future<void> _saveItems(List<Item> items) async {
    final rows = <List<dynamic>>[
      ['id', 'name', 'sku', 'description', 'price', 'quantity', 'created_at'],
      ...items.map((e) => e.toCsv()),
    ];
    await _storage.writeCsv(_items, rows);
  }

  Future<void> _saveSales(List<SaleLine> sales) async {
    final rows = <List<dynamic>>[
      ['sale_id', 'date', 'item_id', 'item_name', 'quantity', 'price', 'total'],
      ...sales.map((e) => e.toCsv()),
    ];
    await _storage.writeCsv(_sales, rows);
  }
}
