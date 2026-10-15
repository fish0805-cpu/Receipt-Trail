import '../purchases/purchase_models.dart';

class ReceiptScanDraft {
  const ReceiptScanDraft({
    this.storeName,
    this.address,
    this.receiptNumber,
    this.total,
    this.date,
    this.rawText,
    this.sellerTaxId,
    this.subtotal,
    this.discount,
    this.items = const <ReceiptItem>[],
    this.itemsComplete = false,
  });

  final String? storeName;
  final String? address;
  final String? receiptNumber;
  final int? total;
  final DateTime? date;
  final String? rawText;
  final String? sellerTaxId;
  final int? subtotal;
  final int? discount;
  final List<ReceiptItem> items;
  final bool itemsComplete;
}

class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}
