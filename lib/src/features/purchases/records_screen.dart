import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../core/formatting/formatters.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../map/navigation_gateway.dart';
import '../prizes/prize_checker.dart';
import '../prizes/prize_models.dart';
import '../prizes/prize_number_repository.dart';
import 'purchase_models.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({
    super.key,
    required this.receipts,
    required this.onOpenMap,
    required this.onDeleteReceipt,
    required this.navigation,
    this.prizeNumbers,
    this.clock,
  });

  final List<Receipt> receipts;
  final VoidCallback onOpenMap;
  final ValueChanged<String> onDeleteReceipt;
  final NavigationGateway navigation;
  final PrizeNumberSource? prizeNumbers;
  final DateTime Function()? clock;

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  SpendingCategory? _category;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final receipts = widget.receipts.where((r) {
      final categoryMatches = _category == null || r.category == _category;
      final queryMatches =
          r.storeName.toLowerCase().contains(_query.toLowerCase());
      return categoryMatches && queryMatches;
    }).toList();
    final monthGroups = _groupReceiptsByMonth(receipts);

    return WarmPageBackground(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(localizations.purchaseRecords,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(localizations.purchaseRecordsSubtitle,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: localizations.searchPurchases),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  Pill(
                      label: localizations.allCategories,
                      selected: _category == null,
                      onTap: () => setState(() => _category = null)),
                  const SizedBox(width: 8),
                  ...SpendingCategory.values.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Pill(
                            label: _categoryLabel(localizations, category),
                            selected: _category == category,
                            onTap: () => setState(() => _category = category)),
                      )),
                ])),
            const SizedBox(height: 18),
            Expanded(
              child: receipts.isEmpty
                  ? Center(child: Text(localizations.noMatchingPurchases))
                  : ListView.separated(
                      itemCount: monthGroups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (_, index) => _ReceiptMonthSection(
                        group: monthGroups[index],
                        navigation: widget.navigation,
                        onOpenMap: widget.onOpenMap,
                        onDeleteReceipt: widget.onDeleteReceipt,
                        prizeNumbers: widget.prizeNumbers,
                        clock: widget.clock,
                      ),
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}

List<_ReceiptMonthGroup> _groupReceiptsByMonth(List<Receipt> receipts) {
  final sorted = List<Receipt>.of(receipts)
    ..sort((a, b) => b.date.compareTo(a.date));
  final grouped = <int, _ReceiptMonthGroup>{};
  for (final receipt in sorted) {
    final key = receipt.date.year * 100 + receipt.date.month;
    grouped
        .putIfAbsent(
          key,
          () => _ReceiptMonthGroup(
            year: receipt.date.year,
            month: receipt.date.month,
          ),
        )
        .receipts
        .add(receipt);
  }
  return grouped.values.toList(growable: false);
}

class _ReceiptMonthGroup {
  _ReceiptMonthGroup({required this.year, required this.month});

  final int year;
  final int month;
  final List<Receipt> receipts = [];

  int get total => receipts.fold(0, (sum, receipt) => sum + receipt.total);
}

class _ReceiptMonthSection extends StatelessWidget {
  const _ReceiptMonthSection({
    required this.group,
    required this.onOpenMap,
    required this.onDeleteReceipt,
    required this.navigation,
    required this.prizeNumbers,
    required this.clock,
  });

  final _ReceiptMonthGroup group;
  final VoidCallback onOpenMap;
  final ValueChanged<String> onDeleteReceipt;
  final NavigationGateway navigation;
  final PrizeNumberSource? prizeNumbers;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.monthGroup(group.year, group.month),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              money(group.total),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < group.receipts.length; index++) ...[
          if (index > 0) const SizedBox(height: 10),
          _ReceiptCard(
            receipt: group.receipts[index],
            navigation: navigation,
            onOpenMap: onOpenMap,
            onDeleteReceipt: onDeleteReceipt,
            prizeNumbers: prizeNumbers,
            clock: clock,
          ),
        ],
      ],
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.receipt,
    required this.onOpenMap,
    required this.onDeleteReceipt,
    required this.navigation,
    required this.prizeNumbers,
    required this.clock,
  });
  final Receipt receipt;
  final VoidCallback onOpenMap;
  final ValueChanged<String> onDeleteReceipt;
  final NavigationGateway navigation;
  final PrizeNumberSource? prizeNumbers;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => _ReceiptDetail(
                  receipt: receipt,
                  navigation: navigation,
                  onOpenMap: onOpenMap,
                  onDeleteReceipt: onDeleteReceipt,
                  prizeNumbers: prizeNumbers,
                  clock: clock,
                )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(17)),
                child: Icon(receipt.category.icon,
                    color: Theme.of(context).colorScheme.primary)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(receipt.storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(
                      '${shortDate(receipt.date, locale: Localizations.localeOf(context).toLanguageTag())} · ${timeOf(receipt.date)}',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 5),
                  Row(children: [
                    Icon(
                        receipt.isSynced
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_off_outlined,
                        size: 14),
                    const SizedBox(width: 4),
                    Text(
                        receipt.isSynced
                            ? localizations.synced
                            : localizations.waitingToSync,
                        style: Theme.of(context).textTheme.labelSmall)
                  ]),
                ])),
            Text(money(receipt.total),
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ]),
        ),
      ),
    );
  }
}

class _ReceiptDetail extends StatelessWidget {
  const _ReceiptDetail({
    required this.receipt,
    required this.onOpenMap,
    required this.onDeleteReceipt,
    required this.navigation,
    required this.prizeNumbers,
    required this.clock,
  });
  final Receipt receipt;
  final VoidCallback onOpenMap;
  final ValueChanged<String> onDeleteReceipt;
  final NavigationGateway navigation;
  final PrizeNumberSource? prizeNumbers;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      localizations.receiptDetails,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PrizeStatusPanel(
                    receipt: receipt,
                    prizeNumbers: prizeNumbers,
                    clock: clock,
                    navigation: navigation,
                  ),
                  const SizedBox(height: 18),
                  Row(children: [
                    CircleAvatar(
                        radius: 24, child: Icon(receipt.category.icon)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(receipt.storeName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900)),
                          Text(receipt.address,
                              maxLines: 1, overflow: TextOverflow.ellipsis)
                        ])),
                    Text(money(receipt.total),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900))
                  ]),
                  const SizedBox(height: 24),
                  Text(
                      '${shortDate(receipt.date, locale: Localizations.localeOf(context).toLanguageTag())}  ${timeOf(receipt.date)} · ${receipt.receiptNumber}',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppPalette.mint.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: localizations.invoicePeriod,
                          value: localizations.invoicePeriodValue(
                            receipt.period.rocYear,
                            receipt.period.endMonth - 1,
                            receipt.period.endMonth,
                          ),
                        ),
                        if (receipt.sellerTaxId case final sellerTaxId?)
                          _DetailRow(
                              label: localizations.sellerTaxId,
                              value: sellerTaxId),
                        _DetailRow(
                          label: localizations.itemsSubtotal,
                          value: money(receipt.subtotal),
                        ),
                        if (receipt.discount > 0)
                          _DetailRow(
                            label: localizations.discount,
                            value: '- ${money(receipt.discount)}',
                          ),
                        _DetailRow(
                          label: localizations.amountPaid,
                          value: money(receipt.total),
                          emphasized: true,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 28),
                  Text(localizations.purchaseItems,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  ...receipt.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Expanded(child: Text(item.name)),
                        Text(item.quantity > 1 ? '× ${item.quantity}' : ''),
                        const SizedBox(width: 18),
                        Text(money(item.price))
                      ]))),
                  if (receipt.rawText != null &&
                      receipt.rawText!.trim().isNotEmpty)
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      leading: const Icon(Icons.text_snippet_outlined),
                      title: Text(localizations.rawOcrText),
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: SelectableText(receipt.rawText!),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onOpenMap();
                            },
                            icon: const Icon(Icons.map_outlined),
                            label: Text(localizations.viewMap))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: FilledButton.icon(
                            onPressed: () => _navigate(context),
                            icon: const Icon(Icons.navigation_rounded),
                            label: Text(localizations.googleNavigation)))
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(localizations.deleteRecord),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ])));
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.deleteRecordTitle),
        content: Text(localizations.deleteRecordBody(receipt.storeName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    Navigator.pop(context);
    onDeleteReceipt(receipt.id);
  }

  Future<void> _navigate(BuildContext context) async {
    final launched = await navigation.openDirections(StoreSummary(
      name: receipt.storeName,
      address: receipt.address,
      visits: 1,
      total: receipt.total,
      lastVisit: receipt.date,
      category: receipt.category,
      latitude: receipt.latitude,
      longitude: receipt.longitude,
    ));
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noMapApp)),
      );
    }
  }
}

class _PrizeStatusPanel extends StatefulWidget {
  const _PrizeStatusPanel({
    required this.receipt,
    required this.prizeNumbers,
    required this.clock,
    required this.navigation,
  });

  final Receipt receipt;
  final PrizeNumberSource? prizeNumbers;
  final DateTime Function()? clock;
  final NavigationGateway navigation;

  @override
  State<_PrizeStatusPanel> createState() => _PrizeStatusPanelState();
}

class _PrizeStatusPanelState extends State<_PrizeStatusPanel> {
  late final Future<PrizeNumberLookup> _lookup =
      widget.prizeNumbers?.get(widget.receipt.period.rocTerm) ??
          Future.value(
            const PrizeNumberLookup(origin: PrizeNumberOrigin.unavailable),
          );

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppPalette.mint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder<PrizeNumberLookup>(
        future: _lookup,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _PrizeStatusText(
              title: localizations.updatingPrizeNumbers,
              subtitle: localizations.offlinePrizeFallback,
            );
          }
          final lookup = snapshot.data ??
              const PrizeNumberLookup(origin: PrizeNumberOrigin.unavailable);
          final result = PrizeChecker.check(
            receiptNumber: widget.receipt.receiptNumber,
            expectedTerm: widget.receipt.period.rocTerm,
            snapshot: lookup.snapshot,
            now: widget.clock?.call() ?? DateTime.now(),
          );
          return _PrizeStatusText(
            title: _title(localizations, result),
            subtitle: _subtitle(localizations, result, lookup),
            onOpenSource: () => widget.navigation.openAttribution(
              Uri.parse(
                lookup.snapshot?.sourceUrl ??
                    'https://invoice.etax.nat.gov.tw/',
              ),
            ),
          );
        },
      ),
    );
  }

  String _title(
    AppLocalizations localizations,
    PrizeCheckResult result,
  ) =>
      switch (result.status) {
        PrizeStatus.awaitingDraw => localizations.prizeAwaitingDraw,
        PrizeStatus.awaitingOfficialNumbers =>
          localizations.prizeAwaitingNumbers,
        PrizeStatus.notWinning => localizations.prizeNotWinning,
        PrizeStatus.winningBeforeClaim => localizations.prizeWinningBeforeClaim(
            _prizeTierLabel(localizations, result.tier),
          ),
        PrizeStatus.claimable => localizations.prizeClaimable(
            _prizeTierLabel(localizations, result.tier),
          ),
        PrizeStatus.expired => localizations.prizeExpired,
        PrizeStatus.verificationRequired => localizations.verifyReceiptNumber,
      };

  String _subtitle(
    AppLocalizations localizations,
    PrizeCheckResult result,
    PrizeNumberLookup lookup,
  ) {
    final snapshot = lookup.snapshot;
    final details = <String>[
      if (lookup.origin == PrizeNumberOrigin.cache &&
          lookup.failureCode != null)
        localizations.prizeOfflineCache
      else if (lookup.origin == PrizeNumberOrigin.cache)
        localizations.prizeLocalCache,
      if (snapshot != null)
        localizations.updatedOn(shortDate(
          snapshot.updatedAt.toLocal(),
          locale: localizations.localeName,
        )),
      if (snapshot != null)
        localizations.dataSource(Uri.parse(snapshot.sourceUrl).host),
    ];
    if (result.status == PrizeStatus.claimable && result.amount != null) {
      final amount = money(result.amount!).replaceFirst('NT\$', 'NT\$ ');
      return [
        localizations.prizeAmount(amount),
        ...details,
        localizations.prizeDisclaimer,
      ].join('\n');
    }
    if (snapshot != null) {
      return [
        ...details,
        if (result.status == PrizeStatus.notWinning)
          localizations.exclusivePrizeDisclaimer,
        localizations.prizeDisclaimer,
      ].join('\n');
    }
    return result.status == PrizeStatus.awaitingDraw
        ? localizations.drawDate(shortDate(
            widget.receipt.period.drawDate,
            locale: localizations.localeName,
          ))
        : localizations.prizeSnapshotUnavailable;
  }
}

class _PrizeStatusText extends StatelessWidget {
  const _PrizeStatusText({
    required this.title,
    required this.subtitle,
    this.onOpenSource,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onOpenSource;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppPalette.forestSoft,
              fontSize: 12,
            ),
          ),
          if (onOpenSource != null)
            TextButton(
              onPressed: onOpenSource,
              child: Text(AppLocalizations.of(context)!.openOfficialSource),
            ),
        ],
      );
}

String _categoryLabel(
  AppLocalizations localizations,
  SpendingCategory category,
) =>
    switch (category) {
      SpendingCategory.food => localizations.categoryFood,
      SpendingCategory.shopping => localizations.categoryShopping,
      SpendingCategory.transport => localizations.categoryTransport,
      SpendingCategory.other => localizations.categoryOther,
    };

String _prizeTierLabel(
  AppLocalizations localizations,
  PrizeTier? tier,
) =>
    switch (tier) {
      PrizeTier.special => localizations.prizeTierSpecial,
      PrizeTier.grand => localizations.prizeTierGrand,
      PrizeTier.first => localizations.prizeTierFirst,
      PrizeTier.second => localizations.prizeTierSecond,
      PrizeTier.third => localizations.prizeTierThird,
      PrizeTier.fourth => localizations.prizeTierFourth,
      PrizeTier.fifth => localizations.prizeTierFifth,
      PrizeTier.sixth => localizations.prizeTierSixth,
      PrizeTier.additionalSixth => localizations.prizeTierAdditionalSixth,
      null => localizations.prizeTierPending,
    };

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            Text(
              value,
              style: TextStyle(
                color: emphasized ? AppPalette.forest : AppPalette.ink,
                fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}
