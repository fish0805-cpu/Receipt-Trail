import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../core/formatting/formatters.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import 'monthly_purchase_summary.dart';
import 'purchase_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.receipts,
    required this.onOpenRecords,
    required this.onOpenMap,
    this.userName,
    this.clock,
  });

  final List<Receipt> receipts;
  final VoidCallback onOpenRecords;
  final VoidCallback onOpenMap;
  final String? userName;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final name = userName?.trim().isNotEmpty == true
        ? userName!.trim()
        : localizations.guestName;

    final summary = MonthlyPurchaseSummary.fromReceipts(
      receipts,
      now: clock?.call() ?? DateTime.now(),
    );

    return WarmPageBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 118),
          children: [
            _Greeting(name: name, clock: clock),
            const SizedBox(height: 20),
            _SpendingHero(
              total: summary.total,
              receiptCount: summary.receiptCount,
              storeCount: summary.storeCount,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.center_focus_strong_rounded,
                    iconColor: AppPalette.coral,
                    title: localizations.scanReceipt,
                    subtitle: localizations.scanAndBookkeep,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(localizations.useCenterScanButton)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.map_outlined,
                    iconColor: AppPalette.forest,
                    title: localizations.viewMap,
                    subtitle: localizations.reviewSpendingTrail,
                    onTap: onOpenMap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(localizations.prizeReminder,
                action: localizations.learnMore),
            const SizedBox(height: 8),
            const _PrizeReminder(),
            const SizedBox(height: 24),
            SectionHeader(localizations.recentPurchases,
                action: localizations.viewAll, onAction: onOpenRecords),
            const SizedBox(height: 8),
            _RecentReceipts(receipts: receipts),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name, this.clock});

  final String name;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final now = clock?.call() ?? DateTime.now();
    final localizations = AppLocalizations.of(context)!;
    final weekdays = [
      localizations.weekdayMonday,
      localizations.weekdayTuesday,
      localizations.weekdayWednesday,
      localizations.weekdayThursday,
      localizations.weekdayFriday,
      localizations.weekdaySaturday,
      localizations.weekdaySunday,
    ];
    final initial = name.characters.first.toUpperCase();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Receipt Trail',
                style: TextStyle(
                  color: AppPalette.forest,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                localizations.homeDate(
                  now.month,
                  now.day,
                  weekdays[now.weekday - 1],
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.forestSoft,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                localizations.homeGreeting(name),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppPalette.ink,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppPalette.mint,
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            initial,
            style: const TextStyle(
              color: AppPalette.forest,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpendingHero extends StatelessWidget {
  const _SpendingHero({
    required this.total,
    required this.receiptCount,
    required this.storeCount,
  });

  final int total;
  final int receiptCount;
  final int storeCount;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppPalette.forest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330E4D3D),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .045),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    localizations.monthlySpending,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      localizations.localRecords,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                money(total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.7,
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.white.withValues(alpha: .16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _HeroMetric(
                          label: localizations.scannedReceipts,
                          value: localizations.receiptCountUnit(receiptCount))),
                  Expanded(
                      child: _HeroMetric(
                          label: localizations.spendingTrail,
                          value: localizations.placeCountUnit(storeCount))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(height: 18),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrizeReminder extends StatelessWidget {
  const _PrizeReminder();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEE7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.emoji_events_outlined,
                  color: AppPalette.coral),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.generalPrizeEnabled,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(localizations.prizeStatusHint,
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppPalette.mint,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(localizations.available,
                  style: const TextStyle(
                      color: AppPalette.forest,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentReceipts extends StatelessWidget {
  const _RecentReceipts({required this.receipts});
  final List<Receipt> receipts;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: receipts.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(child: Text(localizations.noPurchases)),
              )
            : Column(
                children: receipts
                    .take(3)
                    .map((receipt) => _RecentReceipt(receipt: receipt))
                    .toList(),
              ),
      ),
    );
  }
}

class _RecentReceipt extends StatelessWidget {
  const _RecentReceipt({required this.receipt});
  final Receipt receipt;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppPalette.mint,
              child: Icon(receipt.category.icon, color: AppPalette.forest),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(receipt.storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(
                      '${shortDate(receipt.date, locale: Localizations.localeOf(context).toLanguageTag())}  ${timeOf(receipt.date)}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Text(money(receipt.total),
                style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      );
}
