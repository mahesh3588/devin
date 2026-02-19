import 'package:flutter/foundation.dart';

import '../models/item.dart';
import '../services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  InventoryProvider(this._service);

  final InventoryService _service;

  final List<Item> _items = [];
  bool isLoading = false;
  String? error;

  List<Item> get items => List.unmodifiable(_items);

  Future<void> bootstrap() async {
    isLoading = true;
    notifyListeners();
    try {
      await _service.initialize();
      _items
        ..clear()
        ..addAll(await _service.loadItems());
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem({
    required String name,
    required String sku,
    required String description,
    required double price,
    required int quantity,
  }) async {
    await _service.addItem(
      name: name,
      sku: sku,
      description: description,
      price: price,
      quantity: quantity,
    );
    await bootstrap();
  }

  Future<void> updateItem(Item item) async {
    await _service.updateItem(item);
    await bootstrap();
  }

  Future<void> deleteItem(String itemId) async {
    await _service.deleteItem(itemId);
    await bootstrap();
  }

  List<Item> searchItems(String query) {
    final lower = query.toLowerCase();
    return _items.where((item) {
      return item.name.toLowerCase().contains(lower) || item.sku.toLowerCase().contains(lower);
    }).toList();
  }
}
