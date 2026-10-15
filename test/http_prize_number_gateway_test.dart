import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:receipt_trail/src/features/prizes/http_prize_number_gateway.dart';
import 'package:receipt_trail/src/features/prizes/prize_number_repository.dart';

void main() {
  test('fetch parses the public prize snapshot contract', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/prize-numbers/11510');
      return http.Response(
        jsonEncode({
          'term': '11510',
          'special_prize': '11112222',
          'grand_prize': '33334444',
          'first_prizes': ['12345678'],
          'additional_sixth_prizes': ['999'],
          'prize_amounts': {
            'special': 10000000,
            'grand': 2000000,
            'first': 200000,
            'second': 40000,
            'third': 10000,
            'fourth': 4000,
            'fifth': 1000,
            'sixth': 200,
            'additionalSixth': 200,
          },
          'draw_date': '2026-11-25',
          'claim_start_date': '2026-12-06',
          'claim_end_date': '2027-03-05',
          'source_url': 'https://example.test/official',
          'published_at': '2026-11-25T12:00:00Z',
          'updated_at': '2026-11-25T12:00:00Z',
          'checksum':
              'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        }),
        200,
      );
    });
    final gateway = HttpPrizeNumberGateway(
      baseUri: Uri.parse('https://api.example.com'),
      client: client,
    );

    final result = await gateway.fetch('11510');

    expect(result?.term, '11510');
    expect(result?.firstPrizes, ['12345678']);
    expect(result?.claimEndDate, DateTime(2027, 3, 5));
  });

  test('fetch distinguishes a missing term from a server failure', () async {
    final missing = HttpPrizeNumberGateway(
      baseUri: Uri.parse('https://api.example.com'),
      client: MockClient((_) async => http.Response('{}', 404)),
    );
    final failed = HttpPrizeNumberGateway(
      baseUri: Uri.parse('https://api.example.com'),
      client: MockClient((_) async => http.Response('{}', 500)),
    );

    expect(await missing.fetch('11510'), isNull);
    expect(() => failed.fetch('11510'), throwsA(isA<PrizeNumberFailure>()));
  });

  test('malformed successful response becomes a recoverable failure', () {
    final gateway = HttpPrizeNumberGateway(
      baseUri: Uri.parse('https://api.example.com'),
      client: MockClient((_) async => http.Response('{}', 200)),
    );

    expect(() => gateway.fetch('11510'), throwsA(isA<PrizeNumberFailure>()));
  });
}
