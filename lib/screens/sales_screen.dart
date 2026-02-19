import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/invoice_data.dart';
import '../models/item.dart';
import '../providers/inventory_provider.dart';
import '../providers/sales_provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Item? selected;
  final qtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<InventoryProvider, SalesProvider>(
      builder: (context, inventory, sales, _) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              DropdownButtonFormField<Item>(
                value: selected,
                hint: const Text('Select item'),
                items: inventory.items
                    .map((item) => DropdownMenuItem(value: item, child: Text('${item.name} (${item.quantity})')))
                    .toList(),
                onChanged: (value) => setState(() => selected = value),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  if (selected == null) return;
                  final qty = int.tryParse(qtyController.text) ?? 0;
                  if (qty <= 0) return;
                  sales.addLine(InvoiceLine(item: selected!, quantity: qty));
                },
                child: const Text('Add to Bill'),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Text('Tax %'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: sales.taxRate,
                      onChanged: sales.setTaxRate,
                      min: 0,
                      max: 0.3,
                      divisions: 30,
                      label: '${(sales.taxRate * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sales.lines.length,
                  itemBuilder: (context, index) {
                    final line = sales.lines[index];
                    return ListTile(
                      title: Text(line.item.name),
                      subtitle: Text('${line.quantity} × ${line.item.price.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => sales.removeLine(index),
                      ),
                    );
                  },
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _row('Subtotal', sales.subtotal),
                      _row('Tax', sales.tax),
                      _row('Total', sales.total),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  try {
                    await sales.createSale();
                    await context.read<InventoryProvider>().bootstrap();
                    sales.clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale saved')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                label: const Text('Create Sale'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value.toStringAsFixed(2))],
    );
  }
}
