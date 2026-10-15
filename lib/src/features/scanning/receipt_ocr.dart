import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../purchases/purchase_models.dart';

class ReceiptOcrResult {
  const ReceiptOcrResult({
    required this.rawText,
    this.storeName,
    this.address,
    this.receiptNumber,
    this.total,
    this.date,
    this.sellerTaxId,
    this.subtotal,
    this.discount,
    this.items = const <ReceiptItem>[],
  });

  final String rawText;
  final String? storeName;
  final String? address;
  final String? receiptNumber;
  final int? total;
  final DateTime? date;
  final String? sellerTaxId;
  final int? subtotal;
  final int? discount;
  final List<ReceiptItem> items;
}

class ReceiptOcrService {
  Future<ReceiptOcrResult> recognize(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final recognized =
          await recognizer.processImage(InputImage.fromFilePath(imagePath));
      return parseReceiptText(recognized.text);
    } finally {
      await recognizer.close();
    }
  }
}

ReceiptOcrResult parseReceiptText(String rawText) {
  final lines = rawText
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  final numberMatch =
      RegExp(r'\b([A-Z]{2})[-\s]?(\d{8})\b').firstMatch(rawText.toUpperCase());
  final receiptNumber = numberMatch == null
      ? null
      : '${numberMatch.group(1)}${numberMatch.group(2)}';

  final totalMatch = RegExp(
    r'(?:總計|總額|合計|應付|實付|金額)\s*[:：]?\s*(?:NT\$?|\$)?\s*([0-9][0-9,]*)',
    caseSensitive: false,
  ).firstMatch(rawText.replaceAll(' ', ''));
  final total = totalMatch == null
      ? null
      : int.tryParse(totalMatch.group(1)!.replaceAll(',', ''));

  final sellerTaxId = RegExp(
    r'(?:賣方|銷售店|營業人)(?:統一編號|統編)?\s*[:：]?\s*(\d{8})',
  ).firstMatch(rawText)?.group(1);
  int? namedAmount(String label) {
    final match =
        RegExp('$label\\s*[:：]?\\s*-?\\s*(?:NT\\\$?|\\\$)?\\s*([0-9][0-9,]*)')
            .firstMatch(rawText);
    return match == null
        ? null
        : int.tryParse(match.group(1)!.replaceAll(',', ''));
  }

  final subtotal = namedAmount('小計');
  final discount = namedAmount('折扣');
  final items = <ReceiptItem>[];
  final itemPattern = RegExp(r'^(.+?)\s+(\d+)\s+(\d+)\s+(\d+)$');
  for (final line in lines) {
    final match = itemPattern.firstMatch(line);
    if (match == null) continue;
    final quantity = int.tryParse(match.group(2)!);
    final unitPrice = int.tryParse(match.group(3)!);
    final lineTotal = int.tryParse(match.group(4)!);
    if (quantity == null ||
        quantity < 1 ||
        unitPrice == null ||
        lineTotal == null ||
        quantity * unitPrice != lineTotal) {
      continue;
    }
    items.add(ReceiptItem(
      name: match.group(1)!.trim(),
      quantity: quantity,
      price: unitPrice,
    ));
  }

  final dateMatch = RegExp(
    r'\b(\d{3,4})[./年-](\d{1,2})[./月-](\d{1,2})日?\b',
  ).firstMatch(rawText);
  DateTime? date;
  if (dateMatch != null) {
    var year = int.parse(dateMatch.group(1)!);
    if (year < 1911) year += 1911;
    final month = int.parse(dateMatch.group(2)!);
    final day = int.parse(dateMatch.group(3)!);
    final candidate = DateTime(year, month, day);
    if (candidate.month == month && candidate.day == day) date = candidate;
  }

  final address = lines.cast<String?>().firstWhere(
        (line) =>
            line != null &&
            (line.contains('市') || line.contains('縣')) &&
            (line.contains('區') ||
                line.contains('鄉') ||
                line.contains('鎮') ||
                line.contains('市')),
        orElse: () => null,
      );
  final storeName = lines.cast<String?>().firstWhere(
        (line) =>
            line != null &&
            line.length >= 2 &&
            line.length <= 40 &&
            !RegExp(r'發票|收據|統一編號|電話|TEL|\d{3,}').hasMatch(line.toUpperCase()),
        orElse: () => null,
      );

  return ReceiptOcrResult(
    rawText: rawText.trim(),
    storeName: storeName,
    address: address,
    receiptNumber: receiptNumber,
    total: total,
    date: date,
    sellerTaxId: sellerTaxId,
    subtotal: subtotal,
    discount: discount,
    items: List<ReceiptItem>.unmodifiable(items),
  );
}
