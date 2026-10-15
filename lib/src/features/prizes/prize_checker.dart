import '../purchases/invoice_period.dart';
import 'prize_models.dart';

class PrizeChecker {
  static PrizeCheckResult check({
    required String receiptNumber,
    required DateTime now,
    String? expectedTerm,
    PrizeNumberSnapshot? snapshot,
  }) {
    final term = expectedTerm ?? snapshot?.term;
    if (term == null) {
      return const PrizeCheckResult(
        status: PrizeStatus.verificationRequired,
      );
    }

    if (snapshot != null && (snapshot.term != term || !snapshot.isValid)) {
      return const PrizeCheckResult(
        status: PrizeStatus.verificationRequired,
      );
    }

    late final DateTime drawDate;
    try {
      drawDate = snapshot?.drawDate ?? InvoicePeriod.fromRocTerm(term).drawDate;
    } on FormatException {
      return const PrizeCheckResult(
        status: PrizeStatus.verificationRequired,
      );
    }
    final today = _taipeiDateOnly(now);
    if (today.isBefore(_civilDateOnly(drawDate))) {
      return const PrizeCheckResult(status: PrizeStatus.awaitingDraw);
    }
    if (snapshot == null) {
      return const PrizeCheckResult(
        status: PrizeStatus.awaitingOfficialNumbers,
      );
    }
    final match = RegExp(r'^[A-Z]{2}(\d{8})$')
        .firstMatch(receiptNumber.trim().toUpperCase());
    if (match == null) {
      return const PrizeCheckResult(
        status: PrizeStatus.verificationRequired,
      );
    }
    final digits = match.group(1)!;
    final tier = _matchTier(digits, snapshot);
    if (tier == null) {
      return const PrizeCheckResult(status: PrizeStatus.notWinning);
    }

    if (today.isBefore(_civilDateOnly(snapshot.claimStartDate))) {
      return PrizeCheckResult(
        status: PrizeStatus.winningBeforeClaim,
        tier: tier,
        amount: snapshot.prizeAmounts[tier],
      );
    }
    if (today.isAfter(_civilDateOnly(snapshot.claimEndDate))) {
      return PrizeCheckResult(
        status: PrizeStatus.expired,
        tier: tier,
        amount: snapshot.prizeAmounts[tier],
      );
    }
    return PrizeCheckResult(
      status: PrizeStatus.claimable,
      tier: tier,
      amount: snapshot.prizeAmounts[tier],
    );
  }

  static PrizeTier? _matchTier(
    String digits,
    PrizeNumberSnapshot snapshot,
  ) {
    if (digits == snapshot.specialPrize) return PrizeTier.special;
    if (digits == snapshot.grandPrize) return PrizeTier.grand;
    for (final first in snapshot.firstPrizes) {
      if (digits == first) return PrizeTier.first;
    }
    for (final suffixLength in const [7, 6, 5, 4, 3]) {
      if (snapshot.firstPrizes.any(
        (first) => digits.endsWith(first.substring(8 - suffixLength)),
      )) {
        return switch (suffixLength) {
          7 => PrizeTier.second,
          6 => PrizeTier.third,
          5 => PrizeTier.fourth,
          4 => PrizeTier.fifth,
          _ => PrizeTier.sixth,
        };
      }
    }
    if (snapshot.additionalSixthPrizes.any(digits.endsWith)) {
      return PrizeTier.additionalSixth;
    }
    return null;
  }

  static DateTime _civilDateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _taipeiDateOnly(DateTime value) {
    final taipei = value.toUtc().add(const Duration(hours: 8));
    return DateTime(taipei.year, taipei.month, taipei.day);
  }
}
