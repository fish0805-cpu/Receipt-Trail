import '../purchases/purchase_models.dart';

abstract interface class NavigationGateway {
  Future<bool> openDirections(StoreSummary store);
  Future<bool> openPlace(StoreSummary store);
  Future<bool> openAttribution(Uri uri);
}
