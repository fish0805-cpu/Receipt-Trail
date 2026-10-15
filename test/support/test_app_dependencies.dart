import 'package:receipt_trail/src/app/app_dependencies.dart';
import 'package:receipt_trail/src/core/localization/app_locale_controller.dart';
import 'package:receipt_trail/src/features/auth/auth_controller.dart';
import 'package:receipt_trail/src/features/data_management/data_reset_service.dart';
import 'package:receipt_trail/src/features/data_management/export_share_gateway.dart';
import 'package:receipt_trail/src/features/data_management/receipt_export_service.dart';
import 'package:receipt_trail/src/features/map/navigation_gateway.dart';
import 'package:receipt_trail/src/features/purchases/purchase_controller.dart';
import 'package:receipt_trail/src/features/purchases/data/legacy_receipt_importer.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';
import 'package:receipt_trail/src/features/purchases/purchase_repository.dart';
import 'package:receipt_trail/src/features/prizes/prize_number_repository.dart';
import 'package:receipt_trail/src/features/scanning/receipt_scan_models.dart';
import 'package:receipt_trail/src/features/scanning/receipt_scanner.dart';
import 'package:receipt_trail/src/features/sync/receipt_cloud_gateway.dart';
import 'package:receipt_trail/src/features/sync/sync_controller.dart';
import 'package:receipt_trail/src/features/sync/sync_service.dart';
import 'package:receipt_trail/src/features/session/session_coordinator.dart';

TestAppDependencies createTestAppDependencies({
  AppLocaleController? localeController,
}) {
  final purchases = MemoryPurchaseRepository();
  final authController = AuthController.guest();
  final scanner = TestReceiptScanner();
  final sessionCoordinator = SessionCoordinator(
    authController: authController,
    purchases: purchases,
    migration: const _TestMigration(),
    preferences: MemorySessionPreferenceStore(),
  );
  final cloud = _MemoryCloudGateway();
  final syncService = SyncService(purchases, cloud);
  final dependencies = AppDependencies(
    localeController:
        localeController ?? AppLocaleController(_TestLocalePreferenceStore()),
    purchases: purchases,
    purchaseController: PurchaseController(purchases),
    authController: authController,
    sessionCoordinator: sessionCoordinator,
    syncController: SyncController(
      service: syncService,
      repository: purchases,
      authController: authController,
    ),
    receiptScanner: scanner,
    navigation: const _TestNavigationGateway(),
    prizeNumbers: const _EmptyPrizeNumberSource(),
    dataReset: DataResetService(
      repository: purchases,
      syncService: syncService,
      operationStore: MemoryAccountResetOperationStore(),
    ),
    receiptExport: const ReceiptExportService(),
    exportShare: _TestExportShareGateway(),
  );
  return TestAppDependencies(dependencies, scanner);
}

class _TestLocalePreferenceStore implements LocalePreferenceStore {
  @override
  Future<String?> readLocaleTag() async => null;

  @override
  Future<void> writeLocaleTag(String value) async {}
}

class _TestExportShareGateway implements ExportShareGateway {
  @override
  Future<ExportShareResult> share(
    ReceiptExportArchive archive, {
    required String title,
    required String subject,
  }) async =>
      ExportShareResult.completed;
}

class _TestMigration implements LegacyMigration {
  const _TestMigration();

  @override
  Future<LegacyImportResult> importIfNeeded() async => const LegacyImportResult(
        importedCount: 0,
        wasAlreadyComplete: false,
      );
}

class TestAppDependencies {
  const TestAppDependencies(this.dependencies, this.scanner);

  final AppDependencies dependencies;
  final TestReceiptScanner scanner;
}

class TestReceiptScanner implements ReceiptScanner {
  bool disposed = false;

  @override
  Future<ReceiptScanDraft?> analyzeBarcode(
    String rawValue, {
    String? rightValue,
  }) async =>
      null;

  @override
  Future<ReceiptScanDraft?> capture(ScanSource source) async => null;

  @override
  Future<void> dispose() async => disposed = true;

  @override
  Future<GeoPoint?> locateAddress(String address) async => null;
}

class _EmptyPrizeNumberSource implements PrizeNumberSource {
  const _EmptyPrizeNumberSource();

  @override
  Future<PrizeNumberLookup> get(String term) async =>
      const PrizeNumberLookup(origin: PrizeNumberOrigin.unavailable);
}

class _MemoryCloudGateway implements ReceiptCloudGateway {
  @override
  Future<void> deleteAllReceipts(String operationId) async {}

  @override
  Future<void> deleteReceipt(String operationId, String receiptId) async {}

  @override
  Future<List<Receipt>> fetchReceipts() async => const [];

  @override
  Future<void> upsertReceipt(String operationId, Receipt receipt) async {}
}

class _TestNavigationGateway implements NavigationGateway {
  const _TestNavigationGateway();

  @override
  Future<bool> openAttribution(Uri uri) async => true;

  @override
  Future<bool> openDirections(StoreSummary store) async => true;

  @override
  Future<bool> openPlace(StoreSummary store) async => true;
}
