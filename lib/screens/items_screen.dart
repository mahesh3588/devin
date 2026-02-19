import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/inventory_provider.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        final items = query.isEmpty ? provider.items : provider.searchItems(query);

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _showItemDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by name or SKU'),
                onChanged: (value) => setState(() => query = value),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text('${item.name} (${item.sku})'),
                    subtitle: Text('Qty: ${item.quantity} • Price: ${item.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _showItemDialog(context, item: item)),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => context.read<InventoryProvider>().deleteItem(item.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showItemDialog(BuildContext context, {Item? item}) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: item?.name);
    final sku = TextEditingController(text: item?.sku);
    final description = TextEditingController(text: item?.description);
    final price = TextEditingController(text: item?.price.toString());
    final quantity = TextEditingController(text: item?.quantity.toString());

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Item' : 'Update Item'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _field(name, 'Name'),
                _field(sku, 'SKU'),
                _field(description, 'Description'),
                _field(price, 'Price', number: true),
                _field(quantity, 'Quantity', number: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final provider = context.read<InventoryProvider>();
              if (item == null) {
                await provider.addItem(
                  name: name.text.trim(),
                  sku: sku.text.trim(),
                  description: description.text.trim(),
                  price: double.parse(price.text),
                  quantity: int.parse(quantity.text),
                );
              } else {
                await provider.updateItem(
                  item.copyWith(
                    name: name.text.trim(),
                    sku: sku.text.trim(),
                    description: description.text.trim(),
                    price: double.parse(price.text),
                    quantity: int.parse(quantity.text),
                  ),
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }
}
