import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../core/localization/app_locale_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../data_management/data_reset_service.dart';
import '../data_management/export_share_gateway.dart';
import '../session/session_coordinator.dart';
import '../sync/receipt_cloud_gateway.dart';
import 'auth_gateway.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    required this.localeController,
    required this.sessionCoordinator,
    required this.receiptCount,
    required this.storeCount,
    required this.waitingForSyncCount,
    required this.isSyncing,
    required this.syncFailureCode,
    required this.syncedUploadCount,
    required this.hasCompletedSync,
    required this.onSync,
    required this.onExport,
    required this.onReset,
  });

  final AppLocaleController localeController;
  final SessionCoordinator sessionCoordinator;
  final int receiptCount;
  final int storeCount;
  final int waitingForSyncCount;
  final bool isSyncing;
  final SyncFailureCode? syncFailureCode;
  final int? syncedUploadCount;
  final bool hasCompletedSync;
  final Future<void> Function() onSync;
  final Future<ExportShareResult> Function(bool includeOcrText) onExport;
  final Future<void> Function(DataResetTarget target) onReset;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _biometrics = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.sessionCoordinator.authController,
      builder: (context, _) {
        final localizations = AppLocalizations.of(context)!;
        final user = widget.sessionCoordinator.user;
        return WarmPageBackground(
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
              children: [
                Text(localizations.accountTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 22),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user?.name.characters.first.toUpperCase() ??
                              localizations.guestInitial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? localizations.guestName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 18)),
                            const SizedBox(height: 3),
                            Text(user?.email ?? localizations.guestSyncPrompt),
                          ],
                        ),
                      ),
                      Icon(
                        user == null
                            ? Icons.person_outline_rounded
                            : Icons.verified_user_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),
                _Heading(localizations.securityTitle),
                const SizedBox(height: 8),
                Card(
                  child: Column(children: [
                    SwitchListTile(
                      value: _biometrics,
                      onChanged: user == null
                          ? null
                          : (value) {
                              setState(() => _biometrics = value);
                              _notice(localizations.biometricComingSoon);
                            },
                      secondary: const Icon(Icons.fingerprint_rounded),
                      title: Text(localizations.biometricLogin,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(user == null
                          ? localizations.loginFirst
                          : localizations.secureTokenSaved),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      enabled: user != null,
                      leading: const Icon(Icons.lock_outline_rounded),
                      title: Text(localizations.changePassword,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          _notice(localizations.changePasswordUnavailable),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                _Heading(localizations.dataAndSyncTitle),
                const SizedBox(height: 8),
                Card(
                  child: Column(children: [
                    ListTile(
                      leading: Icon(user == null
                          ? Icons.cloud_off_outlined
                          : Icons.cloud_queue_rounded),
                      title: Text(localizations.syncStatus,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(user == null
                          ? localizations.signInToSync
                          : widget.isSyncing
                              ? localizations.syncingData
                              : widget.syncFailureCode != null
                                  ? _syncFailureMessage(
                                      localizations,
                                      widget.syncFailureCode!,
                                    )
                                  : widget.hasCompletedSync &&
                                          (widget.syncedUploadCount ?? 0) > 0
                                      ? localizations.syncedUploadCount(
                                          widget.syncedUploadCount!,
                                        )
                                      : widget.waitingForSyncCount == 0
                                          ? localizations.dataSynced
                                          : localizations.pendingSyncCount(
                                              widget.waitingForSyncCount,
                                            )),
                      trailing: widget.isSyncing
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              tooltip: localizations.syncNow,
                              onPressed: user == null ? null : widget.onSync,
                              icon: Icon(user == null
                                  ? Icons.cloud_off_outlined
                                  : Icons.sync_rounded),
                            ),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.storage_outlined),
                      title: Text(localizations.localData,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(localizations.localDataSummary(
                        widget.receiptCount,
                        widget.storeCount,
                      )),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _notice(localizations.localDataSaved),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.archive_outlined),
                      title: Text(localizations.exportData,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(localizations.exportSubtitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _exportData,
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Icon(Icons.delete_forever_outlined,
                          color: Theme.of(context).colorScheme.error),
                      title: Text(localizations.resetAll,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.error,
                          )),
                      subtitle: Text(user == null
                          ? localizations.resetGuestSubtitle
                          : localizations.resetAccountSubtitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: widget.isSyncing
                          ? null
                          : () => _resetData(user != null),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                _Heading(localizations.preferencesTitle),
                const SizedBox(height: 8),
                Card(
                  child: Column(children: [
                    SwitchListTile(
                      value: _notifications,
                      onChanged: (value) =>
                          setState(() => _notifications = value),
                      secondary: const Icon(Icons.notifications_none_rounded),
                      title: Text(localizations.syncNotifications,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.language_rounded),
                      title: Text(AppLocalizations.of(context)!.language,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(_localeName(
                          AppLocalizations.of(context)!,
                          widget.localeController.option,
                        )),
                        const Icon(Icons.chevron_right_rounded),
                      ]),
                      onTap: _chooseLanguage,
                    ),
                  ]),
                ),
                const SizedBox(height: 22),
                OutlinedButton.icon(
                  onPressed: user == null ? _showAuth : _confirmLogout,
                  icon: Icon(user == null
                      ? Icons.login_rounded
                      : Icons.logout_rounded),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Text(user == null
                        ? localizations.loginOrRegister
                        : localizations.logout),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text('Receipt Trail 0.1.0',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _localeName(
    AppLocalizations localizations,
    AppLocaleOption option,
  ) =>
      switch (option) {
        AppLocaleOption.traditionalChinese => localizations.traditionalChinese,
        AppLocaleOption.english => localizations.english,
      };

  Future<void> _chooseLanguage() async {
    final selected = await showModalBottomSheet<AppLocaleOption>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final localizations = AppLocalizations.of(sheetContext)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLocaleOption.values
                .map(
                  (option) => ListTile(
                    title: Text(_localeName(localizations, option)),
                    trailing: option == widget.localeController.option
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () => Navigator.pop(sheetContext, option),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (selected == null || selected == widget.localeController.option) return;
    try {
      await widget.localeController.select(selected);
    } catch (_) {
      if (mounted) {
        _notice(AppLocalizations.of(context)!.languageSaveFailed);
      }
    }
  }

  Future<void> _exportData() async {
    final localizations = AppLocalizations.of(context)!;
    final includeOcr = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.exportDialogTitle),
        content: Text(localizations.exportDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.includeOcr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.exportWithoutOcr),
          ),
        ],
      ),
    );
    if (includeOcr == null) return;
    try {
      final result = await widget.onExport(includeOcr);
      if (!mounted) return;
      switch (result) {
        case ExportShareResult.completed:
          _notice(localizations.exportCompleted);
        case ExportShareResult.dismissed:
          _notice(localizations.exportDismissed);
        case ExportShareResult.unavailable:
          _notice(localizations.exportUnavailable);
      }
    } catch (_) {
      if (mounted) _notice(localizations.exportFailed);
    }
  }

  Future<void> _resetData(bool isAccount) async {
    final target = await _chooseResetTarget(isAccount);
    if (target == null || !mounted) return;
    final confirmed = await _confirmResetPhrase(target);
    if (!confirmed) return;
    try {
      await widget.onReset(target);
      if (mounted) _notice(AppLocalizations.of(context)!.resetCompleted);
    } on DataResetFailure catch (error) {
      if (mounted) _notice(_dataResetFailureMessage(error.code));
    } catch (_) {
      if (mounted) _notice(AppLocalizations.of(context)!.resetFailed);
    }
  }

  String _dataResetFailureMessage(DataResetFailureCode code) {
    final localizations = AppLocalizations.of(context)!;
    return switch (code) {
      DataResetFailureCode.cloudDeleteUnconfirmed =>
        localizations.cloudDeleteUnconfirmed,
      DataResetFailureCode.noAuthenticatedAccount =>
        localizations.noAuthenticatedAccount,
    };
  }

  String _syncFailureMessage(
    AppLocalizations localizations,
    SyncFailureCode code,
  ) =>
      switch (code) {
        SyncFailureCode.authenticationRequired =>
          localizations.syncAuthenticationRequired,
        SyncFailureCode.networkUnavailable =>
          localizations.syncNetworkUnavailable,
        SyncFailureCode.serviceUnavailable =>
          localizations.syncServiceUnavailable,
        SyncFailureCode.missingLocalReceipt =>
          localizations.syncMissingLocalReceipt,
        SyncFailureCode.invalidResponse => localizations.syncInvalidResponse,
        SyncFailureCode.unknown => localizations.syncUnknownFailure,
      };

  Future<DataResetTarget?> _chooseResetTarget(bool isAccount) {
    final localizations = AppLocalizations.of(context)!;
    if (!isAccount) {
      return showDialog<DataResetTarget>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.clearGuestTitle),
          content: Text(localizations.clearGuestBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                DataResetTarget.guestDevice,
              ),
              child: Text(localizations.continueAction),
            ),
          ],
        ),
      );
    }
    return showDialog<DataResetTarget>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.chooseResetScope),
        content: Text(localizations.chooseResetScopeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              DataResetTarget.accountDevice,
            ),
            child: Text(localizations.clearThisDevice),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              DataResetTarget.accountCloud,
            ),
            child: Text(localizations.clearDeviceAndCloud),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmResetPhrase(DataResetTarget target) async {
    final localizations = AppLocalizations.of(context)!;
    var phrase = '';
    return await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(localizations.finalConfirmation),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(target == DataResetTarget.accountCloud
                      ? localizations.cloudResetWarning
                      : localizations.deviceResetWarning),
                  const SizedBox(height: 14),
                  Text(localizations.deletePhrasePrompt),
                  const SizedBox(height: 8),
                  TextField(
                    autofocus: true,
                    onChanged: (value) =>
                        setDialogState(() => phrase = value.trim()),
                    decoration:
                        InputDecoration(hintText: localizations.deletePhrase),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(localizations.cancel),
                ),
                FilledButton(
                  onPressed: phrase == localizations.deletePhrase
                      ? () => Navigator.pop(context, true)
                      : null,
                  child: Text(localizations.deletePermanently),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  Future<void> _showAuth() async {
    final authenticated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AuthSheet(coordinator: widget.sessionCoordinator),
    );
    if (authenticated == true && mounted) {
      _notice(AppLocalizations.of(context)!.authSuccess);
    }
  }

  Future<void> _confirmLogout() async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logoutTitle),
        content: Text(localizations.logoutBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(localizations.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(localizations.logout)),
        ],
      ),
    );
    if (confirmed == true) await widget.sessionCoordinator.logout();
  }
}

class AuthSheet extends StatefulWidget {
  const AuthSheet({super.key, required this.coordinator});
  final SessionCoordinator coordinator;

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _register = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: widget.coordinator.authController,
      builder: (context, _) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          4,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const BrandMark(size: 48),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Receipt Trail',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900)),
                          Text(localizations.tagline,
                              style: const TextStyle(
                                  color: AppPalette.forestSoft, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                    _register
                        ? localizations.createUser
                        : localizations.welcomeBack,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(_register
                    ? localizations.registerDescription
                    : localizations.loginDescription),
                const SizedBox(height: 20),
                if (_register) ...[
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: localizations.nameLabel,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? localizations.enterName
                        : null,
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    return !email.contains('@') || !email.contains('.')
                        ? localizations.emailInvalid
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: localizations.passwordLabel,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                    ),
                  ),
                  validator: (value) => (value?.length ?? 0) < 8
                      ? localizations.passwordTooShort
                      : null,
                ),
                if (widget.coordinator.authController.errorCode != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _authFailureMessage(
                      localizations,
                      widget.coordinator.authController.errorCode!,
                    ),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: widget.coordinator.authController.isLoading
                      ? null
                      : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: widget.coordinator.authController.isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_register
                            ? localizations.registerAndLogin
                            : localizations.loginOrRegister),
                  ),
                ),
                TextButton(
                  onPressed: widget.coordinator.authController.isLoading
                      ? null
                      : () => setState(() => _register = !_register),
                  child: Text(_register
                      ? localizations.hasAccount
                      : localizations.needsAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _authFailureMessage(
    AppLocalizations localizations,
    AuthFailureCode code,
  ) =>
      switch (code) {
        AuthFailureCode.networkUnavailable =>
          localizations.authNetworkUnavailable,
        AuthFailureCode.serviceUnavailable =>
          localizations.authServiceUnavailable,
        AuthFailureCode.invalidCredentials =>
          localizations.authInvalidCredentials,
        AuthFailureCode.emailAlreadyRegistered =>
          localizations.authEmailAlreadyRegistered,
        AuthFailureCode.sessionExpired => localizations.authSessionExpired,
        AuthFailureCode.malformedResponse =>
          localizations.authMalformedResponse,
        AuthFailureCode.unknown => localizations.authUnknownFailure,
      };

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = _register
        ? await widget.coordinator.register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          )
        : await widget.coordinator.login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    if (success && mounted) Navigator.pop(context, true);
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w900),
      );
}
