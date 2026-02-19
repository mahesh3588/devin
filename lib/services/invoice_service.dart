import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/invoice_data.dart';

class InvoiceService {
  Future<File> generateInvoice(InvoiceData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(data.businessName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Customer: ${data.customerName}'),
            pw.Text('Invoice: ${data.invoiceNumber}'),
            pw.Text('Date: ${data.date.toIso8601String()}'),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Item', 'Qty', 'Price', 'Total'],
              data: data.lines
                  .map((line) => [
                        line.item.name,
                        line.quantity,
                        line.item.price.toStringAsFixed(2),
                        line.total.toStringAsFixed(2),
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 16),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Subtotal: ${data.subtotal.toStringAsFixed(2)}'),
                  pw.Text('Tax: ${data.tax.toStringAsFixed(2)}'),
                  pw.Text('Total: ${data.total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${data.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save(), flush: true);
    return file;
  }

  Future<void> shareInvoice(File file) async {
    await Printing.sharePdf(bytes: await file.readAsBytes(), filename: file.path.split('/').last);
  }
}
