import 'receipt_scan_models.dart';

enum ScanSource { camera, gallery }

enum ScanFailureCode {
  recognitionFailed,
  noTextFound,
  locationUnavailable,
  unknown
}

class ScanFailure implements Exception {
  const ScanFailure(this.code);

  final ScanFailureCode code;

  @override
  String toString() => 'ScanFailure($code)';
}

abstract interface class ReceiptScanner {
  Future<ReceiptScanDraft?> capture(ScanSource source);
  Future<ReceiptScanDraft?> analyzeBarcode(
    String rawValue, {
    String? rightValue,
  });
  Future<GeoPoint?> locateAddress(String address);
  Future<void> dispose();
}
