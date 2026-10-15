import 'dart:async';

import 'package:flutter/foundation.dart';

import 'purchase_models.dart';
import 'purchase_repository.dart';

class PurchaseController extends ChangeNotifier {
  PurchaseController(this._repository) {
    _subscription = _repository.watchReceipts().listen((receipts) {
      _receipts
        ..clear()
        ..addAll(receipts);
      notifyListeners();
    });
  }

  final PurchaseRepository _repository;
  final List<Receipt> _receipts = [];
  late final StreamSubscription<List<Receipt>> _subscription;

  List<Receipt> get receipts => List.unmodifiable(_receipts);

  int get total => _receipts.fold(0, (sum, receipt) => sum + receipt.total);

  int categoryTotal(SpendingCategory category) => _receipts
      .where((receipt) => receipt.category == category)
      .fold(0, (sum, receipt) => sum + receipt.total);

  List<StoreSummary> get stores {
    final grouped = <String, List<Receipt>>{};
    for (final receipt in _receipts) {
      grouped.putIfAbsent(receipt.storeName, () => []).add(receipt);
    }
    return grouped.entries.map((entry) {
      final visits = entry.value;
      visits.sort((a, b) => b.date.compareTo(a.date));
      final result = StoreSummary(
        name: entry.key,
        address: visits.first.address,
        visits: visits.length,
        total: visits.fold(0, (sum, receipt) => sum + receipt.total),
        lastVisit: visits.first.date,
        category: visits.first.category,
        latitude: visits.first.latitude,
        longitude: visits.first.longitude,
      );
      return result;
    }).toList();
  }

  Future<void> saveReceipt(Receipt receipt) => _repository.saveReceipt(receipt);

  Future<void> deleteReceipt(String id) => _repository.deleteReceipt(id);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
