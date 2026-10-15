import '../purchases/invoice_period.dart';

enum PrizeTier {
  special,
  grand,
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  additionalSixth,
}

enum PrizeStatus {
  awaitingDraw,
  awaitingOfficialNumbers,
  notWinning,
  winningBeforeClaim,
  claimable,
  expired,
  verificationRequired,
}

class PrizeNumberSnapshot {
  const PrizeNumberSnapshot({
    required this.term,
    required this.specialPrize,
    required this.grandPrize,
    required this.firstPrizes,
    required this.additionalSixthPrizes,
    required this.prizeAmounts,
    required this.drawDate,
    required this.claimStartDate,
    required this.claimEndDate,
    required this.sourceUrl,
    required this.publishedAt,
    required this.updatedAt,
    required this.checksum,
  });

  final String term;
  final String specialPrize;
  final String grandPrize;
  final List<String> firstPrizes;
  final List<String> additionalSixthPrizes;
  final Map<PrizeTier, int> prizeAmounts;
  final DateTime drawDate;
  final DateTime claimStartDate;
  final DateTime claimEndDate;
  final String sourceUrl;
  final DateTime publishedAt;
  final DateTime updatedAt;
  final String checksum;

  factory PrizeNumberSnapshot.fromJson(Map<String, dynamic> json) {
    final amountJson = json['prize_amounts'] as Map<String, dynamic>;
    final snapshot = PrizeNumberSnapshot(
      term: json['term'] as String,
      specialPrize: json['special_prize'] as String,
      grandPrize: json['grand_prize'] as String,
      firstPrizes: List<String>.from(json['first_prizes'] as List),
      additionalSixthPrizes:
          List<String>.from(json['additional_sixth_prizes'] as List),
      prizeAmounts: {
        for (final tier in PrizeTier.values) tier: amountJson[tier.name] as int,
      },
      drawDate: DateTime.parse(json['draw_date'] as String),
      claimStartDate: DateTime.parse(json['claim_start_date'] as String),
      claimEndDate: DateTime.parse(json['claim_end_date'] as String),
      sourceUrl: json['source_url'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      checksum: json['checksum'] as String,
    );
    if (!snapshot.isValid) {
      throw const FormatException('Invalid prize snapshot');
    }
    return snapshot;
  }

  bool get isValid {
    final termMatch = RegExp(r'^\d{5}$').hasMatch(term);
    final endMonth = termMatch ? int.tryParse(term.substring(3)) : null;
    final source = Uri.tryParse(sourceUrl);
    DateTime? expectedDraw;
    if (termMatch) {
      try {
        expectedDraw = InvoicePeriod.fromRocTerm(term).drawDate;
      } on FormatException {
        expectedDraw = null;
      }
    }
    return termMatch &&
        int.parse(term.substring(0, 3)) > 0 &&
        const {2, 4, 6, 8, 10, 12}.contains(endMonth) &&
        RegExp(r'^\d{8}$').hasMatch(specialPrize) &&
        RegExp(r'^\d{8}$').hasMatch(grandPrize) &&
        firstPrizes.isNotEmpty &&
        firstPrizes.toSet().length == firstPrizes.length &&
        firstPrizes.every(RegExp(r'^\d{8}$').hasMatch) &&
        additionalSixthPrizes.toSet().length == additionalSixthPrizes.length &&
        additionalSixthPrizes.every(RegExp(r'^\d{3}$').hasMatch) &&
        prizeAmounts.length == PrizeTier.values.length &&
        PrizeTier.values.every((tier) => (prizeAmounts[tier] ?? 0) > 0) &&
        !claimStartDate.isBefore(drawDate) &&
        !claimEndDate.isBefore(claimStartDate) &&
        expectedDraw != null &&
        _sameCivilDate(drawDate, expectedDraw) &&
        source != null &&
        source.scheme == 'https' &&
        source.hasAuthority &&
        source.host.isNotEmpty &&
        RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(checksum);
  }

  static bool _sameCivilDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Map<String, dynamic> toJson() => {
        'term': term,
        'special_prize': specialPrize,
        'grand_prize': grandPrize,
        'first_prizes': firstPrizes,
        'additional_sixth_prizes': additionalSixthPrizes,
        'prize_amounts': {
          for (final entry in prizeAmounts.entries) entry.key.name: entry.value,
        },
        'draw_date': drawDate.toIso8601String(),
        'claim_start_date': claimStartDate.toIso8601String(),
        'claim_end_date': claimEndDate.toIso8601String(),
        'source_url': sourceUrl,
        'published_at': publishedAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'checksum': checksum,
      };
}

class PrizeCheckResult {
  const PrizeCheckResult({required this.status, this.tier, this.amount});

  final PrizeStatus status;
  final PrizeTier? tier;
  final int? amount;
}
