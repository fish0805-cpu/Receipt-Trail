import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'prize_models.dart';
import 'prize_number_repository.dart';

class SharedPreferencesPrizeNumberCache implements PrizeNumberCache {
  const SharedPreferencesPrizeNumberCache(this.preferences);

  static const _prefix = 'prize_number_snapshot.';
  final SharedPreferences preferences;

  @override
  Future<PrizeNumberSnapshot?> load(String term) async {
    final value = preferences.getString('$_prefix$term');
    if (value == null) return null;
    try {
      final json = jsonDecode(value);
      return json is Map<String, dynamic>
          ? PrizeNumberSnapshot.fromJson(json)
          : null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> save(PrizeNumberSnapshot snapshot) async {
    await preferences.setString(
      '$_prefix${snapshot.term}',
      jsonEncode(snapshot.toJson()),
    );
  }
}
