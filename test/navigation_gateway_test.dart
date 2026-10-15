import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/features/map/url_launcher_navigation_gateway.dart';
import 'package:receipt_trail/src/features/purchases/purchase_models.dart';

void main() {
  test('directions use seven-decimal coordinates when available', () async {
    Uri? launched;
    final gateway = UrlLauncherNavigationGateway(
      launcher: (uri) async {
        launched = uri;
        return true;
      },
    );

    await gateway.openDirections(_store(latitude: 25.03, longitude: 121.53));

    expect(launched?.queryParameters['destination'], '25.0300000,121.5300000');
    expect(launched?.queryParameters['travelmode'], 'driving');
  });

  test('place search uses store and address without coordinates', () async {
    Uri? launched;
    final gateway = UrlLauncherNavigationGateway(
      launcher: (uri) async {
        launched = uri;
        return true;
      },
    );

    await gateway.openPlace(_store());
    expect(launched?.queryParameters['query'], '綠日咖啡, 台北市信義區');

    await gateway.openPlace(_store(address: ''));
    expect(launched?.queryParameters['query'], '綠日咖啡');
  });

  test('launcher exceptions become a false result', () async {
    final gateway = UrlLauncherNavigationGateway(
      launcher: (_) async => throw StateError('unavailable'),
    );

    expect(await gateway.openPlace(_store()), isFalse);
  });
}

StoreSummary _store({
  String address = '台北市信義區',
  double? latitude,
  double? longitude,
}) => StoreSummary(
  name: '綠日咖啡',
  address: address,
  visits: 1,
  total: 100,
  lastVisit: DateTime(2026, 10, 13),
  category: SpendingCategory.food,
  latitude: latitude,
  longitude: longitude,
);
