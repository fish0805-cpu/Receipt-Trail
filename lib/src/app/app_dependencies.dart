import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_locale_controller.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/http_auth_gateway.dart';
import '../features/auth/token_store.dart';
import '../features/data_management/data_reset_service.dart';
import '../features/data_management/export_share_gateway.dart';
import '../features/data_management/receipt_export_service.dart';
import '../features/map/navigation_gateway.dart';
import '../features/map/url_launcher_navigation_gateway.dart';
import '../features/purchases/purchase_controller.dart';
import '../features/purchases/data/drift_purchase_repository.dart';
import '../features/purchases/data/legacy_receipt_importer.dart';
import '../features/purchases/data/receipt_trail_database.dart';
import '../features/purchases/purchase_repository.dart';
import '../features/prizes/http_prize_number_gateway.dart';
import '../features/prizes/prize_number_repository.dart';
import '../features/prizes/shared_preferences_prize_number_cache.dart';
import '../features/scanning/device_receipt_scanner.dart';
import '../features/scanning/receipt_scanner.dart';
import '../features/sync/http_receipt_cloud_gateway.dart';
import '../features/sync/sync_controller.dart';
import '../features/sync/sync_service.dart';
import '../features/session/drift_session_preference_store.dart';
import '../features/session/session_coordinator.dart';

Uri resolveBackendBaseUri({
  required String configuredValue,
  required bool isRelease,
}) {
  final value = configuredValue.trim();
  if (value.isEmpty && isRelease) {
    throw StateError(
      'Release builds require AUTH_API_BASE_URL to be configured.',
    );
  }
  final uri = Uri.parse(value.isEmpty ? 'http://10.0.2.2:8000' : value);
  const reservedExampleDomains = {'example.com', 'example.org', 'example.net'};
  final normalizedHost = uri.host.toLowerCase();
  final usesReservedExampleDomain = reservedExampleDomains.any(
    (domain) => normalizedHost == domain || normalizedHost.endsWith('.$domain'),
  );
  if (isRelease &&
      (uri.scheme != 'https' ||
          !uri.hasAuthority ||
          uri.host.isEmpty ||
          usesReservedExampleDomain)) {
    throw StateError(
      'Release builds require a valid HTTPS backend URL.',
    );
  }
  return uri;
}

/// Owns the long-lived services used by the application.
///
/// Screens receive these dependencies instead of constructing platform or
/// network adapters themselves. Tests can use the public constructor with
/// memory and fake implementations.
class AppDependencies {
  AppDependencies({
    required this.localeController,
    required this.purchases,
    required this.purchaseController,
    required this.authController,
    required this.sessionCoordinator,
    required this.syncController,
    required this.receiptScanner,
    required this.navigation,
    required this.prizeNumbers,
    required this.dataReset,
    required this.receiptExport,
    required this.exportShare,
  });

  final AppLocaleController localeController;
  final PurchaseRepository purchases;
  final PurchaseController purchaseController;
  final AuthController authController;
  final SessionCoordinator sessionCoordinator;
  final SyncController syncController;
  final ReceiptScanner receiptScanner;
  final NavigationGateway navigation;
  final PrizeNumberSource prizeNumbers;
  final DataResetService dataReset;
  final ReceiptExportService receiptExport;
  final ExportShareGateway exportShare;

  bool _isDisposed = false;

  static Future<AppDependencies> create({Uri? backendBaseUri}) async {
    final database = ReceiptTrailDatabase();
    final purchases = DriftPurchaseRepository(database);
    final preferences = await SharedPreferences.getInstance();
    final localeController = await AppLocaleController.load(
      SharedPreferencesLocalePreferenceStore(preferences),
    );
    final baseUri = backendBaseUri ??
        resolveBackendBaseUri(
          configuredValue: const String.fromEnvironment('AUTH_API_BASE_URL'),
          isRelease: kReleaseMode,
        );
    final authController = AuthController(
      HttpAuthGateway(baseUri: baseUri),
      SecureTokenStore(),
    );
    final purchaseController = PurchaseController(purchases);
    final syncService = SyncService(
      purchases,
      HttpReceiptCloudGateway(
        authController: authController,
        baseUri: baseUri,
      ),
    );
    final syncController = SyncController(
      service: syncService,
      repository: purchases,
      authController: authController,
      autoSyncOnAuth: false,
    );
    final sessionCoordinator = SessionCoordinator(
      authController: authController,
      purchases: purchases,
      migration: LegacyReceiptImporter(
        SharedPreferencesLegacyReceiptStore(preferences),
        purchases,
      ),
      preferences: DriftSessionPreferenceStore(database),
      onAccountReady: syncController.sync,
      runExclusiveOperation: syncController.runExclusiveOperation,
    );
    return AppDependencies(
      localeController: localeController,
      purchases: purchases,
      purchaseController: purchaseController,
      authController: authController,
      sessionCoordinator: sessionCoordinator,
      syncController: syncController,
      receiptScanner: DeviceReceiptScanner(),
      navigation: UrlLauncherNavigationGateway(),
      prizeNumbers: PrizeNumberRepository(
        gateway: HttpPrizeNumberGateway(baseUri: baseUri),
        cache: SharedPreferencesPrizeNumberCache(preferences),
      ),
      dataReset: DataResetService(
        repository: purchases,
        syncService: syncService,
        operationStore:
            SharedPreferencesAccountResetOperationStore(preferences),
      ),
      receiptExport: const ReceiptExportService(),
      exportShare: const SharePlusExportShareGateway(),
    );
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    localeController.dispose();
    syncController.dispose();
    purchaseController.dispose();
    authController.dispose();
    sessionCoordinator.dispose();
    unawaited(receiptScanner.dispose());
    unawaited(purchases.close());
  }
}
