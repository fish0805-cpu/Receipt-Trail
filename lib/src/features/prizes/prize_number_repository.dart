import 'prize_models.dart';

enum PrizeNumberFailureCode {
  networkUnavailable,
  serviceUnavailable,
  invalidData
}

class PrizeNumberFailure implements Exception {
  const PrizeNumberFailure(this.code, {this.statusCode});
  final PrizeNumberFailureCode code;
  final int? statusCode;
}

abstract interface class PrizeNumberGateway {
  Future<PrizeNumberSnapshot?> fetch(String term);
}

abstract interface class PrizeNumberCache {
  Future<PrizeNumberSnapshot?> load(String term);
  Future<void> save(PrizeNumberSnapshot snapshot);
}

abstract interface class PrizeNumberSource {
  Future<PrizeNumberLookup> get(String term);
}

enum PrizeNumberOrigin { online, cache, unavailable }

class PrizeNumberLookup {
  const PrizeNumberLookup({
    required this.origin,
    this.snapshot,
    this.failureCode,
  });

  final PrizeNumberOrigin origin;
  final PrizeNumberSnapshot? snapshot;
  final PrizeNumberFailureCode? failureCode;
}

class PrizeNumberRepository implements PrizeNumberSource {
  const PrizeNumberRepository({required this.gateway, required this.cache});

  final PrizeNumberGateway gateway;
  final PrizeNumberCache cache;

  @override
  Future<PrizeNumberLookup> get(String term) async {
    try {
      final remote = await gateway.fetch(term);
      if (remote != null) {
        if (!remote.isValid || remote.term != term) {
          throw const PrizeNumberFailure(PrizeNumberFailureCode.invalidData);
        }
        await cache.save(remote);
        return PrizeNumberLookup(
          origin: PrizeNumberOrigin.online,
          snapshot: remote,
        );
      }
      final cached = await cache.load(term);
      return PrizeNumberLookup(
        origin: cached == null
            ? PrizeNumberOrigin.unavailable
            : PrizeNumberOrigin.cache,
        snapshot: cached,
      );
    } on PrizeNumberFailure catch (error) {
      final cached = await cache.load(term);
      return PrizeNumberLookup(
        origin: cached == null
            ? PrizeNumberOrigin.unavailable
            : PrizeNumberOrigin.cache,
        snapshot: cached,
        failureCode: error.code,
      );
    }
  }
}
