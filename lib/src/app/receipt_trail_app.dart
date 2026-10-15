import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme.dart';
import '../features/session/session_coordinator.dart';
import '../features/session/welcome_screen.dart';
import 'app_dependencies.dart';
import 'app_shell.dart';
import '../../l10n/generated/app_localizations.dart';

class ReceiptTrailApp extends StatefulWidget {
  const ReceiptTrailApp({
    super.key,
    required this.dependencies,
  });

  final AppDependencies dependencies;

  @override
  State<ReceiptTrailApp> createState() => _ReceiptTrailAppState();
}

class _ReceiptTrailAppState extends State<ReceiptTrailApp> {
  @override
  void dispose() {
    widget.dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.dependencies.localeController,
      builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: widget.dependencies.localeController.locale,
        supportedLocales: const [Locale('zh', 'TW'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: ListenableBuilder(
          listenable: widget.dependencies.sessionCoordinator,
          builder: (context, _) =>
              switch (widget.dependencies.sessionCoordinator.stage) {
            SessionStage.loading => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            SessionStage.welcome => WelcomeScreen(
                coordinator: widget.dependencies.sessionCoordinator,
              ),
            SessionStage.guest ||
            SessionStage.account =>
              AppShell(dependencies: widget.dependencies),
            SessionStage.migrationFailure => SessionRepairScreen(
                coordinator: widget.dependencies.sessionCoordinator,
              ),
          },
        ),
      ),
    );
  }
}
