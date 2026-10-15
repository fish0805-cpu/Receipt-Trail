import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../auth/account_screen.dart';
import 'session_coordinator.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.coordinator});

  final SessionCoordinator coordinator;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: WarmPageBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: BrandMark(size: 76)),
                        const SizedBox(height: 20),
                        Text(
                          localizations.welcomeTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          localizations.welcomeDescription,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: () => _showAuth(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(localizations.loginOrRegister),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: coordinator.continueAsGuest,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(localizations.continueAsGuest),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          localizations.guestMigrationNote,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppPalette.forestSoft,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAuth(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => AuthSheet(coordinator: coordinator),
  );
}

class SessionRepairScreen extends StatelessWidget {
  const SessionRepairScreen({super.key, required this.coordinator});

  final SessionCoordinator coordinator;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: WarmPageBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.storage_rounded, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        localizations.dataRepairTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(switch (coordinator.failureCode) {
                        SessionFailureCode.initialMigration =>
                          localizations.dataMigrationFailed,
                        SessionFailureCode.guestClaim =>
                          localizations.guestClaimFailed,
                        SessionFailureCode.repair =>
                          localizations.dataRepairFailed,
                        null => localizations.dataRepairFallback,
                      }, textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: coordinator.retryMigration,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(localizations.retryDataRepair),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
