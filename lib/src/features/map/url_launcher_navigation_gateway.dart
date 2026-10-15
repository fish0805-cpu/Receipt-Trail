import 'package:url_launcher/url_launcher.dart';

import '../purchases/purchase_models.dart';
import 'navigation_gateway.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri);

class UrlLauncherNavigationGateway implements NavigationGateway {
  UrlLauncherNavigationGateway({ExternalUrlLauncher? launcher})
    : _launcher = launcher ?? _launchExternally;

  final ExternalUrlLauncher _launcher;

  static Future<bool> _launchExternally(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Future<bool> openDirections(StoreSummary store) => _open(
    Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': _destination(store),
      'travelmode': 'driving',
      'dir_action': 'navigate',
    }),
  );

  @override
  Future<bool> openPlace(StoreSummary store) => _open(
    Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': _destination(store),
    }),
  );

  @override
  Future<bool> openAttribution(Uri uri) => _open(uri);

  Future<bool> _open(Uri uri) async {
    try {
      return await _launcher(uri);
    } catch (_) {
      return false;
    }
  }

  String _destination(StoreSummary store) {
    if (store.latitude != null && store.longitude != null) {
      return '${store.latitude!.toStringAsFixed(7)},${store.longitude!.toStringAsFixed(7)}';
    }
    return store.address.trim().isEmpty
        ? store.name
        : '${store.name}, ${store.address}';
  }
}
