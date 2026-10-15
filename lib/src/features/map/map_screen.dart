import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:latlong2/latlong.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../core/formatting/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../purchases/purchase_models.dart';
import 'navigation_gateway.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.stores,
    required this.selectedStore,
    required this.onSelectStore,
    required this.onOpenRecords,
    required this.navigation,
  });

  final List<StoreSummary> stores;
  final StoreSummary? selectedStore;
  final ValueChanged<StoreSummary?> onSelectStore;
  final VoidCallback onOpenRecords;
  final NavigationGateway navigation;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  late final Future<vt.Style> _mapStyle;
  SpendingCategory? _category;

  @override
  void initState() {
    super.initState();
    _mapStyle = const vt.StyleReader(
      uri: 'asset://assets/styles/receipt_trail_map.json',
    ).read();
  }

  @override
  void dispose() {
    _mapStyle.then((style) => style.dispose()).ignore();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stores.length != widget.stores.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitStores(_mapped(widget.stores));
      });
    }
  }

  List<StoreSummary> _mapped(List<StoreSummary> stores) => stores
      .where((store) => store.latitude != null && store.longitude != null)
      .toList();

  void _fitStores(List<StoreSummary> stores) {
    if (stores.isEmpty) return;
    if (stores.length == 1) {
      _mapController.move(
        LatLng(stores.first.latitude!, stores.first.longitude!),
        17,
      );
      return;
    }
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(stores
            .map((store) => LatLng(store.latitude!, store.longitude!))
            .toList()),
        padding: const EdgeInsets.fromLTRB(48, 170, 48, 180),
        maxZoom: 17,
      ),
    );
  }

  void _selectStore(StoreSummary store) {
    widget.onSelectStore(store);
    _mapController.move(LatLng(store.latitude!, store.longitude!), 17.5);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final stores = widget.stores
        .where((s) => _category == null || s.category == _category)
        .toList();
    final mappedStores = _mapped(stores);
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: FutureBuilder<vt.Style>(
            future: _mapStyle,
            builder: (context, snapshot) {
              final style = snapshot.data;
              if (style == null) {
                return ColoredBox(
                  color: const Color(0xFFEEF2ED),
                  child: Center(
                    child: snapshot.hasError
                        ? Text(localizations.mapLoadFailed)
                        : const CircularProgressIndicator(),
                  ),
                );
              }
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(23.7, 121),
                  initialZoom: 7.2,
                  maxZoom: 20,
                  onMapReady: () => _fitStores(mappedStores),
                ),
                children: [
                  vt.VectorTileLayer(
                    theme: style.theme,
                    tileProviders: style.providers,
                    rasterSources: style.rasterSources,
                    sprites: style.sprites,
                  ),
                  MarkerLayer(
                    markers: mappedStores
                        .map(
                          (store) => Marker(
                            point: LatLng(store.latitude!, store.longitude!),
                            width: 150,
                            height: 76,
                            alignment: Alignment.topCenter,
                            child: _MapPin(
                              store: store,
                              selected: widget.selectedStore == store,
                              onTap: () => _selectStore(store),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  RichAttributionWidget(
                    showFlutterMapAttribution: false,
                    attributions: [
                      TextSourceAttribution(
                        'OpenFreeMap · OpenStreetMap',
                        onTap: () => widget.navigation.openAttribution(
                          Uri.parse('https://openfreemap.org/'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        if (mappedStores.isEmpty)
          Center(
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                child: Text(
                    stores.isEmpty
                        ? localizations.mapEmpty
                        : localizations.mapNoLocations,
                    textAlign: TextAlign.center),
              ),
            ),
          ),
        SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 13),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x18000000),
                                          blurRadius: 16)
                                    ]),
                                child: Row(children: [
                                  const BrandMark(size: 38),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(localizations.mySpendingTrail,
                                            style:
                                                const TextStyle(fontSize: 10)),
                                        const Text('Receipt Trail',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.search_rounded)
                                ]))),
                        const SizedBox(width: 10),
                        FloatingActionButton.small(
                            heroTag: 'locate',
                            onPressed: mappedStores.isEmpty
                                ? null
                                : () {
                                    final store = mappedStores.first;
                                    _mapController.move(
                                      LatLng(store.latitude!, store.longitude!),
                                      17,
                                    );
                                    _selectStore(store);
                                  },
                            backgroundColor: Colors.white,
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.my_location_rounded)),
                      ]),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            Pill(
                                label: localizations.allCategories,
                                selected: _category == null,
                                onTap: () => setState(() {
                                      _category = null;
                                      widget.onSelectStore(null);
                                    })),
                            const SizedBox(width: 8),
                            ...SpendingCategory.values
                                .take(3)
                                .map((category) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Pill(
                                        label: _mapCategoryLabel(
                                          localizations,
                                          category,
                                        ),
                                        selected: _category == category,
                                        onTap: () => setState(() {
                                              _category = category;
                                              widget.onSelectStore(null);
                                            })))),
                          ])),
                      const Spacer(),
                    ]))),
      ]),
    );
  }
}

class StoreNavigationPanel extends StatelessWidget {
  const StoreNavigationPanel({
    super.key,
    required this.store,
    required this.navigation,
    required this.onOpenRecords,
    required this.onClose,
  });

  final StoreSummary store;
  final NavigationGateway navigation;
  final VoidCallback onOpenRecords;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 330,
        child: StoreNavigationCard(
          store: store,
          navigation: navigation,
          onOpenRecords: onOpenRecords,
          onClose: onClose,
        ),
      );
}

class _MapPin extends StatelessWidget {
  const _MapPin(
      {required this.store, required this.selected, required this.onTap});
  final StoreSummary store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(maxWidth: 145),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 8),
              ],
            ),
            child: Text(
              store.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : const Color(0xFF173F32),
              ),
            ),
          ),
          const SizedBox(height: 1),
          Stack(
            alignment: const Alignment(0, -0.25),
            children: [
              Icon(
                Icons.location_pin,
                color: selected
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.primary,
                size: selected ? 46 : 42,
                shadows: const [
                  Shadow(color: Color(0x55000000), blurRadius: 6),
                ],
              ),
              Icon(store.category.icon, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class StoreNavigationCard extends StatelessWidget {
  const StoreNavigationCard({
    super.key,
    required this.store,
    required this.navigation,
    required this.onClose,
    required this.onOpenRecords,
  });
  final StoreSummary store;
  final NavigationGateway navigation;
  final VoidCallback onClose;
  final VoidCallback onOpenRecords;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 12,
      shadowColor: const Color(0x33000000),
      clipBehavior: Clip.antiAlias,
      child: Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(store.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900))),
              IconButton(
                  onPressed: onClose, icon: const Icon(Icons.close_rounded))
            ]),
            Text(store.address,
                maxLines: 2, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _Metric(
                  label: localizations.visitCount,
                  value: localizations.visitCountValue(store.visits)),
              _Metric(
                  label: localizations.totalSpending,
                  value: money(store.total)),
              _Metric(
                  label: localizations.averageSpending,
                  value: money(store.average)),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => _openPlace(context),
                      child: Text(localizations.googleMaps))),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                    onPressed: () => _navigate(context),
                    icon: const Icon(Icons.navigation_rounded),
                    label: Text(localizations.startNavigation)),
              )
            ]),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onOpenRecords,
                child: Text(localizations.viewPurchaseRecords),
              ),
            ),
          ])),
    );
  }

  Future<void> _navigate(BuildContext context) async {
    var launched = false;
    try {
      launched = await navigation.openDirections(store);
    } catch (_) {
      // Platform URL launchers can be unavailable even after capability checks.
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noMapApp)),
      );
    }
  }

  Future<void> _openPlace(BuildContext context) async {
    var launched = false;
    try {
      launched = await navigation.openPlace(store);
    } catch (_) {
      // Keep the map usable when the external application cannot be opened.
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotOpenGoogleMaps)),
      );
    }
  }
}

String _mapCategoryLabel(
  AppLocalizations localizations,
  SpendingCategory category,
) =>
    switch (category) {
      SpendingCategory.food => localizations.categoryFood,
      SpendingCategory.shopping => localizations.categoryShopping,
      SpendingCategory.transport => localizations.categoryTransport,
      SpendingCategory.other => localizations.categoryOther,
    };

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900))
      ]);
}
