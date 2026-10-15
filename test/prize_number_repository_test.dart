import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/prizes/prize_models.dart';
import 'package:receipt_trail/src/features/prizes/prize_number_repository.dart';

final _snapshot = PrizeNumberSnapshot(
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
  checksum: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
);

void main() {
  test('successful online snapshot is cached for later offline use', () async {
    final cache = _MemoryPrizeCache();
    final online = PrizeNumberRepository(
      gateway: _PrizeGateway(_snapshot),
      cache: cache,
    );

    final onlineResult = await online.get('11510');
    expect(onlineResult.snapshot, same(_snapshot));
    expect(onlineResult.origin, PrizeNumberOrigin.online);

    final offline = PrizeNumberRepository(
      gateway: _PrizeGateway.failure(),
      cache: cache,
    );
    final cached = await offline.get('11510');
    expect(cached.origin, PrizeNumberOrigin.cache);
    expect(cached.failureCode, PrizeNumberFailureCode.networkUnavailable);
    expect(cached.snapshot?.checksum,
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
    expect(cached.snapshot?.firstPrizes, ['12345678']);
  });

  test('missing online term remains unknown when cache is empty', () async {
    final repository = PrizeNumberRepository(
      gateway: _PrizeGateway(null),
      cache: _MemoryPrizeCache(),
    );

    final result = await repository.get('11508');
    expect(result.origin, PrizeNumberOrigin.unavailable);
    expect(result.snapshot, isNull);
  });
}

class _PrizeGateway implements PrizeNumberGateway {
  _PrizeGateway(this.value) : failure = null;
  _PrizeGateway.failure()
      : value = null,
        failure = const PrizeNumberFailure(
          PrizeNumberFailureCode.networkUnavailable,
        );

  final PrizeNumberSnapshot? value;
  final PrizeNumberFailure? failure;

  @override
  Future<PrizeNumberSnapshot?> fetch(String term) async {
    if (failure case final error?) throw error;
    return value;
  }
}

class _MemoryPrizeCache implements PrizeNumberCache {
  final values = <String, PrizeNumberSnapshot>{};

  @override
  Future<PrizeNumberSnapshot?> load(String term) async => values[term];

  @override
  Future<void> save(PrizeNumberSnapshot snapshot) async {
    values[snapshot.term] = snapshot;
  }
}
