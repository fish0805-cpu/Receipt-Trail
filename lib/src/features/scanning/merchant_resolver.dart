import '../purchases/purchase_models.dart';

enum MerchantMatchReason { taxId, nameAndAddress }

class MerchantCandidate {
  const MerchantCandidate({
    required this.storeName,
    required this.address,
    required this.sellerTaxId,
    required this.reason,
  });

  final String storeName;
  final String address;
  final String? sellerTaxId;
  final MerchantMatchReason reason;
}

/// Suggests existing merchants, but never changes the scanned draft itself.
class MerchantResolver {
  static List<MerchantCandidate> resolve({
    required Iterable<Receipt> receipts,
    String? sellerTaxId,
    String? storeName,
    String? address,
  }) {
    final tax = sellerTaxId?.trim() ?? '';
    final name = _normalize(storeName);
    final location = _normalize(address);
    final seen = <String>{};
    final matches = <MerchantCandidate>[];

    for (final receipt in receipts) {
      final receiptTax = receipt.sellerTaxId?.trim() ?? '';
      final taxMatches = tax.isNotEmpty && receiptTax == tax;
      final nameAndAddressMatch = name.isNotEmpty &&
          location.isNotEmpty &&
          _normalize(receipt.storeName) == name &&
          _normalize(receipt.address) == location;
      if (!taxMatches && !nameAndAddressMatch) continue;

      final key = '${_normalize(receipt.storeName)}|'
          '${_normalize(receipt.address)}|$receiptTax';
      if (!seen.add(key)) continue;
      matches.add(MerchantCandidate(
        storeName: receipt.storeName,
        address: receipt.address,
        sellerTaxId: receipt.sellerTaxId,
        reason: taxMatches
            ? MerchantMatchReason.taxId
            : MerchantMatchReason.nameAndAddress,
      ));
    }
    matches.sort((a, b) => a.reason.index.compareTo(b.reason.index));
    return List.unmodifiable(matches);
  }

  static String _normalize(String? value) => (value ?? '')
      .toLowerCase()
      .replaceAll('臺', '台')
      .replaceAll(RegExp(r'[\s、，,．.－-]'), '');
}
