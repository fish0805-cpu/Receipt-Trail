import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/prizes/prize_models.dart';
import 'package:receipt_trail/src/features/prizes/shared_preferences_prize_number_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('snapshot survives a shared preferences cache round trip', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final cache = SharedPreferencesPrizeNumberCache(preferences);
    final snapshot = PrizeNumberSnapshot(
      term: '11510',
      specialPrize: '11112222',
      grandPrize: '33334444',
      firstPrizes: const ['12345678'],
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
      checksum:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    );

    await cache.save(snapshot);
    final restored = await cache.load('11510');

    expect(restored?.checksum,
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
    expect(restored?.additionalSixthPrizes, ['999']);
  });
}
