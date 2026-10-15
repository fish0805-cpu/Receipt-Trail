import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/account_screen.dart';
import '../features/data_management/data_reset_service.dart';
import '../features/data_management/export_share_gateway.dart';
import '../features/map/map_screen.dart';
import '../features/purchases/home_screen.dart';
import '../features/purchases/purchase_models.dart';
import '../features/purchases/records_screen.dart';
import '../features/scanning/scan_screen.dart';
import 'app_dependencies.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.dependencies,
  });

  final AppDependencies dependencies;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  StoreSummary? _selectedMapStore;
  Future<void> _openScanner() async {
    final Receipt? receipt = await Navigator.of(context).push<Receipt>(
      MaterialPageRoute<Receipt>(
        builder: (_) => ScanScreen(
          scanner: widget.dependencies.receiptScanner,
          existingReceipts: widget.dependencies.purchaseController.receipts,
          onSaveReceipt: widget.dependencies.purchaseController.saveReceipt,
        ),
      ),
    );
    if (receipt != null) {
      if (mounted) setState(() => _index = 0);
      await widget.dependencies.syncController.sync();
    }
  }

  Future<void> _deleteReceipt(String id) =>
      widget.dependencies.syncController.deleteReceipt(id);

  Future<ExportShareResult> _exportData(bool includeOcrText) async {
    final archive = widget.dependencies.receiptExport.buildArchive(
      receipts: widget.dependencies.purchaseController.receipts,
      exportedAt: DateTime.now(),
      ownerType: widget.dependencies.authController.isAuthenticated
          ? 'account'
          : 'guest',
      includeOcrText: includeOcrText,
    );
    final localizations = AppLocalizations.of(context)!;
    return widget.dependencies.exportShare.share(
      archive,
      title: localizations.exportShareTitle,
      subject: localizations.exportShareSubject,
    );
  }

  Future<void> _resetData(DataResetTarget target) async {
    if (target == DataResetTarget.accountDevice) {
      final user = widget.dependencies.authController.user;
      if (user == null) {
        throw const DataResetFailure(
          DataResetFailureCode.noAuthenticatedAccount,
        );
      }
      await widget.dependencies.sessionCoordinator.logout(
        beforeLogout: () =>
            widget.dependencies.dataReset.clearAccountFromDevice(user.id),
      );
      return;
    }
    await widget.dependencies.syncController.runExclusiveOperation(() async {
      final user = widget.dependencies.authController.user;
      switch (target) {
        case DataResetTarget.guestDevice:
          await widget.dependencies.dataReset.clearGuestData();
          return;
        case DataResetTarget.accountDevice:
          throw StateError('accountDevice is handled before this operation');
        case DataResetTarget.accountCloud:
          if (user == null) {
            throw const DataResetFailure(
              DataResetFailureCode.noAuthenticatedAccount,
            );
          }
          await widget.dependencies.dataReset.clearAccountEverywhere(
            userId: user.id,
          );
          return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      extendBody: true,
      body: ListenableBuilder(
        listenable: Listenable.merge([
          widget.dependencies.purchaseController,
          widget.dependencies.syncController,
          widget.dependencies.authController,
        ]),
        builder: (context, _) {
          final purchases = widget.dependencies.purchaseController;
          final sync = widget.dependencies.syncController;
          return Stack(
            children: <Widget>[
              IndexedStack(
                index: _index,
                children: [
                  HomeScreen(
                    receipts: purchases.receipts,
                    userName: widget.dependencies.authController.user?.name,
                    onOpenRecords: () => setState(() => _index = 1),
                    onOpenMap: () => setState(() => _index = 3),
                  ),
                  RecordsScreen(
                    receipts: purchases.receipts,
                    onOpenMap: () => setState(() => _index = 3),
                    onDeleteReceipt: _deleteReceipt,
                    navigation: widget.dependencies.navigation,
                    prizeNumbers: widget.dependencies.prizeNumbers,
                  ),
                  const SizedBox.shrink(),
                  MapScreen(
                    stores: purchases.stores,
                    selectedStore: _selectedMapStore,
                    onSelectStore: (store) =>
                        setState(() => _selectedMapStore = store),
                    onOpenRecords: () => setState(() {
                      _selectedMapStore = null;
                      _index = 1;
                    }),
                    navigation: widget.dependencies.navigation,
                  ),
                  AccountScreen(
                    localeController: widget.dependencies.localeController,
                    sessionCoordinator: widget.dependencies.sessionCoordinator,
                    receiptCount: purchases.receipts.length,
                    storeCount: purchases.stores.length,
                    waitingForSyncCount: purchases.receipts
                        .where((receipt) => !receipt.isSynced)
                        .length,
                    isSyncing: sync.isSyncing,
                    syncFailureCode: sync.failureCode,
                    syncedUploadCount: sync.uploadedCount,
                    hasCompletedSync: sync.hasCompletedSync,
                    onSync: sync.sync,
                    onExport: _exportData,
                    onReset: _resetData,
                  ),
                ],
              ),
              if (_index == 3 && _selectedMapStore != null)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 100,
                  child: StoreNavigationPanel(
                    store: _selectedMapStore!,
                    navigation: widget.dependencies.navigation,
                    onOpenRecords: () => setState(() {
                      _selectedMapStore = null;
                      _index = 1;
                    }),
                    onClose: () => setState(() => _selectedMapStore = null),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .96),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              height: 76,
              backgroundColor: Colors.transparent,
              indicatorColor: AppPalette.mint,
              selectedIndex: _index,
              onDestinationSelected: (value) {
                if (value == 2) {
                  _openScanner();
                } else {
                  setState(() {
                    _index = value;
                    if (value != 3) _selectedMapStore = null;
                  });
                }
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: localizations.navOverview,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.receipt_long_outlined),
                  selectedIcon: const Icon(Icons.receipt_long_rounded),
                  label: localizations.navReceipts,
                ),
                NavigationDestination(
                  icon: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppPalette.forest,
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x330E4D3D),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.center_focus_strong_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  label: localizations.navScan,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.map_outlined),
                  selectedIcon: const Icon(Icons.map_rounded),
                  label: localizations.navMap,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: localizations.navAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
