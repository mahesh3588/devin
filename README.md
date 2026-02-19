# Flutter CSV Inventory Management App

A complete inventory management mobile app built with Flutter using **CSV files as local embedded database**.

## Features

- Item management (add, update, delete, list, search)
- Billing/sales management with subtotal, tax, total
- Stock ledger (IN/OUT) with automatic balance updates
- PDF invoice generation and local save
- Provider state management
- Clean architecture-inspired folder structure

## Folder Structure

```text
lib/
  models/
  providers/
  screens/
  services/
  utils/
  widgets/
  main.dart
assets/
  csv/
    items.csv
    sales.csv
    ledger.csv
```

## CSV schemas

- `items.csv`: `id,name,sku,description,price,quantity,created_at`
- `sales.csv`: `sale_id,date,item_id,item_name,quantity,price,total`
- `ledger.csv`: `ledger_id,item_id,date,transaction_type,quantity,balance_after`

## Setup

1. Install Flutter (latest stable)
2. Run:
   ```bash
   flutter pub get
   flutter run
   ```
3. On first launch, app copies CSV templates from assets to app documents directory.

## CSV initialization (example)

`InventoryService.initialize()` ensures all files exist:

- `assets/csv/items.csv`
- `assets/csv/sales.csv`
- `assets/csv/ledger.csv`

using `CsvStorageService.ensureFileExists(...)`.

## Required functions

Implemented in services/providers:

- `addItem()` in `InventoryService`
- `updateItem()` in `InventoryService`
- `deleteItem()` in `InventoryService`
- `createSale()` in `InventoryService` and `SalesProvider`
- `updateStock()` in `InventoryService`
- `generateInvoice()` in `InvoiceService` and `SalesProvider`

## Concurrency and data safety

`CsvStorageService` serializes writes with an internal `_writeQueue` to avoid concurrent CSV corruption.
