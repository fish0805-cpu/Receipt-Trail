import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' hide GeoPoint;

import 'receipt_ocr.dart';
import 'receipt_scan_models.dart';
import 'receipt_scanner.dart';
import 'taiwan_invoice_qr.dart';

class DeviceReceiptScanner implements ReceiptScanner {
  DeviceReceiptScanner({
    ImagePicker? imagePicker,
    ReceiptOcrService? ocr,
    Geocoding? geocoding,
    MobileScannerController? imageScanner,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _ocr = ocr ?? ReceiptOcrService(),
        _geocoding = geocoding ?? Geocoding(),
        _imageScanner = imageScanner ??
            MobileScannerController(
              formats: const [BarcodeFormat.qrCode],
              detectionSpeed: DetectionSpeed.noDuplicates,
            );

  final ImagePicker _imagePicker;
  final ReceiptOcrService _ocr;
  final Geocoding _geocoding;
  final MobileScannerController _imageScanner;

  @override
  Future<ReceiptScanDraft?> capture(ScanSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source == ScanSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: source == ScanSource.camera ? 90 : null,
      );
      if (image == null) return null;
      if (source == ScanSource.gallery) {
        final capture = await _imageScanner.analyzeImage(image.path);
        final values = capture?.barcodes
                .map((barcode) => barcode.rawValue?.trim())
                .whereType<String>()
                .toList() ??
            const <String>[];
        final left = values
            .where((value) => parseTaiwanInvoiceQr(value) != null)
            .firstOrNull;
        if (left != null) {
          final right =
              values.where((value) => value.startsWith('**')).firstOrNull;
          final qrDraft = await analyzeBarcode(left, rightValue: right);
          if (qrDraft != null) return qrDraft;
        }
      }
      final result = await _ocr.recognize(image.path);
      if (result.rawText.isEmpty) {
        throw const ScanFailure(ScanFailureCode.noTextFound);
      }
      return ReceiptScanDraft(
        storeName: result.storeName,
        address: result.address,
        receiptNumber: result.receiptNumber,
        total: result.total,
        date: result.date,
        rawText: result.rawText,
        sellerTaxId: result.sellerTaxId,
        subtotal: result.subtotal,
        discount: result.discount,
        items: result.items,
      );
    } on ScanFailure {
      rethrow;
    } catch (_) {
      throw const ScanFailure(ScanFailureCode.recognitionFailed);
    }
  }

  @override
  Future<ReceiptScanDraft?> analyzeBarcode(
    String rawValue, {
    String? rightValue,
  }) async {
    final data = parseTaiwanInvoiceQr(rawValue, rightValue: rightValue);
    if (data == null) return null;
    return ReceiptScanDraft(
      receiptNumber: data.receiptNumber,
      total: data.total,
      date: data.date,
      sellerTaxId: data.sellerTaxId,
      items: data.items,
      itemsComplete: data.itemsComplete,
    );
  }

  @override
  Future<GeoPoint?> locateAddress(String address) async {
    try {
      final locations = await _geocoding.locationFromAddress(address);
      if (locations.isEmpty) return null;
      return GeoPoint(
        latitude: locations.first.latitude,
        longitude: locations.first.longitude,
      );
    } catch (_) {
      throw const ScanFailure(ScanFailureCode.locationUnavailable);
    }
  }

  @override
  Future<void> dispose() => _imageScanner.dispose();
}
