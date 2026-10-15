import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/prizes/prize_checker.dart';
import 'package:receipt_trail/src/features/prizes/prize_models.dart';

final _snapshot = PrizeNumberSnapshot(
  term: '11510',
  specialPrize: '11112222',
  grandPrize: '33334444',
  firstPrizes: const ['12345678', '87654321', '13572468'],
  additionalSixthPrizes: const ['999'],
  prizeAmounts: const {
    PrizeTier.special: 10000000,
    PrizeTier.grand: 2000000,
    PrizeTier.first: 200000,
    PrizeTier.second: 40000,
    PrizeTier.third: 10000,
    PrizeTier.fourth: 4000,
    PrizeTier.fifth: 1000,
    PrizeTier.sixth: 200,
    PrizeTier.additionalSixth: 200,
  },
  drawDate: DateTime(2026, 11, 25),
  claimStartDate: DateTime(2026, 12, 6),
  claimEndDate: DateTime(2027, 3, 5),
  sourceUrl: 'https://example.test/official',
  publishedAt: DateTime.utc(2026, 11, 25),
  updatedAt: DateTime.utc(2026, 11, 25),
  checksum: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
);

void main() {
  test('matches the highest applicable general invoice prize', () {
    final cases = <String, PrizeTier>{
      '11112222': PrizeTier.special,
      '33334444': PrizeTier.grand,
      '12345678': PrizeTier.first,
      '02345678': PrizeTier.second,
      '00345678': PrizeTier.third,
      '00045678': PrizeTier.fourth,
      '00005678': PrizeTier.fifth,
      '00000678': PrizeTier.sixth,
      '00000999': PrizeTier.additionalSixth,
    };

    for (final entry in cases.entries) {
      final result = PrizeChecker.check(
        receiptNumber: 'AB${entry.key}',
        snapshot: _snapshot,
        now: DateTime(2026, 12, 20),
      );
      expect(result.tier, entry.value, reason: entry.key);
      expect(result.amount, _snapshot.prizeAmounts[entry.value],
          reason: entry.key);
      expect(result.status, PrizeStatus.claimable, reason: entry.key);
    }
  });

  test('reports draw, publication, claim and expiry states truthfully', () {
    expect(
      PrizeChecker.check(
        receiptNumber: 'AB12345678',
        expectedTerm: '11510',
        now: DateTime(2026, 11, 20),
      ).status,
      PrizeStatus.awaitingDraw,
    );
    expect(
      PrizeChecker.check(
        receiptNumber: 'AB12345678',
        expectedTerm: '11510',
        now: DateTime(2026, 11, 26),
      ).status,
      PrizeStatus.awaitingOfficialNumbers,
    );
    expect(
      PrizeChecker.check(
        receiptNumber: 'AB12345678',
        snapshot: _snapshot,
        now: DateTime(2026, 12, 1),
      ).status,
      PrizeStatus.winningBeforeClaim,
    );
    expect(
      PrizeChecker.check(
        receiptNumber: 'AB12345678',
        snapshot: _snapshot,
        now: DateTime(2027, 3, 6),
      ).status,
      PrizeStatus.expired,
    );
  });

  test('does not claim a result for malformed or mismatched data', () {
    expect(
      PrizeChecker.check(
        receiptNumber: '未填寫',
        snapshot: _snapshot,
        now: DateTime(2026, 12, 20),
      ).status,
      PrizeStatus.verificationRequired,
    );
    expect(
      PrizeChecker.check(
        receiptNumber: 'AB12345678',
        expectedTerm: '11508',
        snapshot: _snapshot,
        now: DateTime(2026, 12, 20),
      ).status,
      PrizeStatus.verificationRequired,
    );
    expect(
      PrizeChecker.check(
        receiptNumber: 'AB22222222',
        snapshot: _snapshot,
        now: DateTime(2026, 12, 20),
      ).status,
      PrizeStatus.notWinning,
    );
  });

  test('validates snapshot before using its date or number suffixes', () {
    final mismatchedFuture = PrizeNumberSnapshot(
      term: '11512',
      specialPrize: '11112222',
      grandPrize: '33334444',
      firstPrizes: const ['12345678'],
      additionalSixthPrizes: const [],
      prizeAmounts: _snapshot.prizeAmounts,
      drawDate: DateTime(2027, 1, 25),
      claimStartDate: DateTime(2027, 2, 6),
      claimEndDate: DateTime(2027, 5, 5),
      sourceUrl: 'https://example.test/official',
      publishedAt: DateTime.utc(2027, 1, 25),
      updatedAt: DateTime.utc(2027, 1, 25),
      checksum:
          'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
    );
    final malformed = PrizeNumberSnapshot(
      term: '11510',
      specialPrize: '1',
      grandPrize: '2',
      firstPrizes: const ['123'],
      additionalSixthPrizes: const ['9'],
      prizeAmounts: _snapshot.prizeAmounts,
      drawDate: DateTime(2026, 11, 25),
      claimStartDate: DateTime(2026, 12, 6),
      claimEndDate: DateTime(2027, 3, 5),
      sourceUrl: 'https://example.test/official',
      publishedAt: DateTime.utc(2026, 11, 25),
      updatedAt: DateTime.utc(2026, 11, 25),
      checksum:
          'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
    );

    expect(
      PrizeChecker.check(
        receiptNumber: 'AB12345678',
        expectedTerm: '11510',
        snapshot: mismatchedFuture,
        now: DateTime(2026, 12, 20),
      ).status,
      PrizeStatus.verificationRequired,
    );
    expect(
      PrizeChecker.check(
        receiptNumber: 'AB12345678',
        snapshot: malformed,
        now: DateTime(2026, 12, 20),
      ).status,
      PrizeStatus.verificationRequired,
    );
  });

  test('claim boundaries follow Taiwan civil time for travellers', () {
    final beforeTaiwanMidnight = PrizeChecker.check(
      receiptNumber: 'AB12345678',
      snapshot: _snapshot,
      now: DateTime.utc(2026, 12, 5, 15, 59),
    );
    final atTaiwanMidnight = PrizeChecker.check(
      receiptNumber: 'AB12345678',
      snapshot: _snapshot,
      now: DateTime.utc(2026, 12, 5, 16),
    );

    expect(beforeTaiwanMidnight.status, PrizeStatus.winningBeforeClaim);
    expect(atTaiwanMidnight.status, PrizeStatus.claimable);
  });
}
