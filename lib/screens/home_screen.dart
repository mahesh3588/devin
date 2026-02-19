import 'package:flutter/material.dart';

import 'invoice_screen.dart';
import 'items_screen.dart';
import 'sales_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const screens = [ItemsScreen(), SalesScreen(), InvoiceScreen()];

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Items'),
          NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), label: 'Sales'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Invoice'),
        ],
      ),
    );
  }
}
