import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class CsvStorageService {
  Future<void> _writeQueue = Future.value();

  Future<Directory> get _dir async => getApplicationDocumentsDirectory();

  Future<File> _resolveFile(String fileName) async {
    final directory = await _dir;
    return File('${directory.path}/$fileName');
  }

  Future<void> ensureFileExists({
    required String fileName,
    required String assetPath,
  }) async {
    final file = await _resolveFile(fileName);
    if (!await file.exists()) {
      final data = await rootBundle.loadString(assetPath);
      await file.writeAsString(data, flush: true);
    }
  }

  Future<List<List<dynamic>>> readCsv(String fileName) async {
    final file = await _resolveFile(fileName);
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return [];
    }
    return const CsvToListConverter(shouldParseNumbers: false).convert(raw);
  }

  Future<void> writeCsv(String fileName, List<List<dynamic>> rows) async {
    _writeQueue = _writeQueue.then((_) async {
      final file = await _resolveFile(fileName);
      final csv = const ListToCsvConverter().convert(rows);
      await file.writeAsString('$csv\n', flush: true);
    });

    return _writeQueue;
  }
}
