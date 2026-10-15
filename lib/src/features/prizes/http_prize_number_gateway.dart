import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'prize_models.dart';
import 'prize_number_repository.dart';

class HttpPrizeNumberGateway implements PrizeNumberGateway {
  HttpPrizeNumberGateway({required this.baseUri, http.Client? client})
      : _client = client ?? http.Client();

  final Uri baseUri;
  final http.Client _client;

  @override
  Future<PrizeNumberSnapshot?> fetch(String term) async {
    try {
      final response = await _client
          .get(baseUri.resolve('/prize-numbers/${Uri.encodeComponent(term)}'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) {
        throw PrizeNumberFailure(
          PrizeNumberFailureCode.serviceUnavailable,
          statusCode: response.statusCode,
        );
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const PrizeNumberFailure(PrizeNumberFailureCode.invalidData);
      }
      return PrizeNumberSnapshot.fromJson(json);
    } on TimeoutException {
      throw const PrizeNumberFailure(
        PrizeNumberFailureCode.networkUnavailable,
      );
    } on http.ClientException {
      throw const PrizeNumberFailure(
        PrizeNumberFailureCode.networkUnavailable,
      );
    } on FormatException {
      throw const PrizeNumberFailure(PrizeNumberFailureCode.invalidData);
    } on TypeError {
      throw const PrizeNumberFailure(PrizeNumberFailureCode.invalidData);
    }
  }
}
