import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/inventory_provider.dart';
import 'providers/sales_provider.dart';
import 'screens/home_screen.dart';
import 'services/csv_storage_service.dart';
import 'services/inventory_service.dart';
import 'services/invoice_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = CsvStorageService();
  final inventoryService = InventoryService(storage);
  final invoiceService = InvoiceService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider(inventoryService)..bootstrap()),
        ChangeNotifierProvider(create: (_) => SalesProvider(inventoryService, invoiceService)),
      ],
      child: const InventoryApp(),
    ),
  );
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV Inventory Manager',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
