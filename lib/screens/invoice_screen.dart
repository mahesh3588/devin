import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sales_provider.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final businessController = TextEditingController(text: 'My Business');
  final customerController = TextEditingController();
  File? invoiceFile;

  @override
  void dispose() {
    businessController.dispose();
    customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Consumer<SalesProvider>(
        builder: (context, sales, _) {
          return ListView(
            children: [
              TextField(controller: businessController, decoration: const InputDecoration(labelText: 'Business Name')),
              const SizedBox(height: 8),
              TextField(controller: customerController, decoration: const InputDecoration(labelText: 'Customer Name')),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: sales.lines.isEmpty
                    ? null
                    : () async {
                        final file = await sales.generateInvoice(
                          businessName: businessController.text.trim(),
                          customerName: customerController.text.trim(),
                        );
                        setState(() => invoiceFile = file);
                      },
                child: const Text('Generate Invoice PDF'),
              ),
              const SizedBox(height: 8),
              if (invoiceFile != null)
                FilledButton.tonal(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invoice saved: ${invoiceFile!.path}')),
                    );
                  },
                  child: const Text('Invoice Saved Locally'),
                ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoice Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Business: ${businessController.text}'),
                      Text('Customer: ${customerController.text}'),
                      Text('Subtotal: ${sales.subtotal.toStringAsFixed(2)}'),
                      Text('Tax: ${sales.tax.toStringAsFixed(2)}'),
                      Text('Total: ${sales.total.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
