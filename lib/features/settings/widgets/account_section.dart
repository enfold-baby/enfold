import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/api/api_exception.dart';
import '../../../services/auth/account_switch_service.dart';
import '../../../services/auth/auth_providers.dart';
import '../../../services/sync/sync_providers.dart';
import '../../../services/sync/sync_service.dart';

class AccountSection extends ConsumerStatefulWidget {
  const AccountSection({super.key});

  @override
  ConsumerState<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends ConsumerState<AccountSection> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  String? _devCode;
  String? _status;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String _requestCodeErrorMessage(AppL10n l10n, Object error) {
    if (error is ApiException) {
      if (error.statusCode == 422) {
        return l10n.settingsAccountInvalidEmail;
      }
      if (error.statusCode == 503) {
        return l10n.settingsAccountCodeBusy;
      }
      return l10n.settingsAccountCodeFailedWithMessage(error.message);
    }
    return l10n.settingsAccountCodeFailedOffline;
  }

  Future<void> _requestCode() async {
    final l10n = AppL10n.of(context);
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final devCode = await ref
          .read(authSessionProvider.notifier)
          .requestMagicCode(_emailController.text);
      setState(() {
        _codeSent = true;
        _devCode = kDebugMode ? devCode : null;
        _status = l10n.settingsAccountCodeSent;
      });
    } catch (e) {
      setState(() => _status = _requestCodeErrorMessage(l10n, e));
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<AccountSwitchChoice?> _promptAccountSwitch() {
    return showDialog<AccountSwitchChoice>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppL10n.of(context);
        return AlertDialog(
          key: const Key('account_switch_dialog'),
          title: Text(
            l10n.settingsAccountSwitchTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          content: Text(
            l10n.settingsAccountSwitchBody,
            style: GoogleFonts.nunito(),
          ),
          actions: [
            TextButton(
              key: const Key('account_switch_cancel'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              key: const Key('account_switch_upload'),
              onPressed: () =>
                  Navigator.of(context).pop(AccountSwitchChoice.uploadLocal),
              child: Text(l10n.settingsAccountSwitchUpload),
            ),
            FilledButton(
              key: const Key('account_switch_fresh'),
              onPressed: () =>
                  Navigator.of(context).pop(AccountSwitchChoice.startFresh),
              child: Text(l10n.settingsAccountSwitchFresh),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verify() async {
    final l10n = AppL10n.of(context);
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final switchService = ref.read(accountSwitchServiceProvider);

      await ref.read(authSessionProvider.notifier).verifyMagicCode(
            email: _emailController.text,
            code: _codeController.text,
          );
      final session = ref.read(authSessionProvider).valueOrNull;
      if (session == null) {
        setState(() => _status = l10n.settingsAccountCodeInvalid);
        return;
      }

      // First sign-in on this install (e.g. a reinstall): restore the whole
      // history, not just the recent sync window.
      var fullHistory = await switchService.lastSignedInUserId() == null;
      if (await switchService.isAccountSwitch(session.user.id)) {
        if (!mounted) return;
        final choice = await _promptAccountSwitch();
        if (choice == null) {
          await ref.read(authSessionProvider.notifier).signOut();
          setState(() => _status = l10n.settingsAccountSignInCancelled);
          return;
        }
        await switchService.applySwitchChoice(choice);
        fullHistory = choice == AccountSwitchChoice.startFresh;
      }

      final result = await ref
          .read(syncActionsProvider)
          .syncIfSignedIn(fullHistory: fullHistory);
      await switchService.setLastSignedInUserId(session.user.id);

      setState(() {
        _status = result.ok
            ? _syncStatusMessage(
                l10n,
                result,
                prefix: l10n.settingsAccountSignedIn,
              )
            : l10n.settingsAccountSignedInSyncRetry('${result.error}');
      });
    } catch (e) {
      setState(() => _status = l10n.settingsAccountCodeInvalid);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _syncStatusMessage(
    AppL10n l10n,
    SyncResult result, {
    required String prefix,
  }) {
    final parts = <String>[prefix];
    if (result.pushed > 0) {
      parts.add(l10n.settingsAccountSyncPushed(result.pushed));
    }
    if (result.pulled > 0) {
      parts.add(l10n.settingsAccountSyncPulled(result.pulled));
    }
    if (parts.length == 1) parts.add(l10n.settingsAccountSyncUpToDate);
    return '${parts.join(' · ')}.';
  }

  Future<void> _signOut({bool clearDeviceData = false}) async {
    final l10n = AppL10n.of(context);
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      if (clearDeviceData) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            key: const Key('sign_out_clear_dialog'),
            title: Text(
              l10n.settingsAccountClearTitle,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
            content: Text(
              l10n.settingsAccountClearBody,
              style: GoogleFonts.nunito(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                key: const Key('sign_out_clear_confirm'),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.settingsAccountClearConfirm),
              ),
            ],
          ),
        );
        if (confirmed != true) return;

        final switchService = ref.read(accountSwitchServiceProvider);
        await switchService.clearLocalCareData();
        await switchService.setLastSignedInUserId(null);
      }

      await ref.read(authSessionProvider.notifier).signOut();
      setState(() {
        _codeSent = false;
        _devCode = null;
        _status = clearDeviceData
            ? l10n.settingsAccountSignedOutCleared
            : null;
        _codeController.clear();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAccount() async {
    final l10n = AppL10n.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('delete_account_dialog'),
        title: Text(
          l10n.settingsAccountDeleteTitle,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        content: Text(
          l10n.settingsAccountDeleteBody,
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const Key('delete_account_confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.bloomDeep,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.settingsAccountDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await ref.read(authSessionProvider.notifier).deleteAccount();
      await ref.read(accountSwitchServiceProvider).clearLocalCareData();
      await ref.read(accountSwitchServiceProvider).setLastSignedInUserId(null);
      if (!mounted) return;
      setState(() {
        _codeSent = false;
        _devCode = null;
        _codeController.clear();
        _status = l10n.settingsAccountDeleted;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = l10n.settingsAccountDeleteFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppL10n.of(context);
    final sessionAsync = ref.watch(authSessionProvider);
    final session = sessionAsync.valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            l10n.settingsAccountTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            session == null
                ? l10n.settingsAccountSignedOutSubtitle
                : l10n.settingsAccountSignedInAs(session.user.email),
            style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (session == null) ...[
                TextField(
                  key: const Key('auth_email'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l10n.settingsAccountEmailLabel,
                    hintText: 'you@example.com',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('auth_send_code'),
                  onPressed: _busy ? null : _requestCode,
                  child: Text(
                    _codeSent
                        ? l10n.settingsAccountResendCode
                        : l10n.settingsAccountSendCode,
                  ),
                ),
                if (_codeSent) ...[
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('auth_code'),
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.settingsAccountCodeLabel,
                    ),
                  ),
                  if (_devCode != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.settingsAccountDevCode('$_devCode'),
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.accent(brightness),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton(
                    key: const Key('auth_verify'),
                    onPressed: _busy ? null : _verify,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bloom,
                      foregroundColor: AppColors.cream,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(l10n.settingsAccountVerify),
                  ),
                ],
              ] else ...[
                OutlinedButton(
                  key: const Key('auth_sign_out'),
                  onPressed: _busy ? null : () => _signOut(),
                  child: Text(l10n.settingsAccountSignOut),
                ),
                const SizedBox(height: 8),
                TextButton(
                  key: const Key('auth_sign_out_clear'),
                  onPressed:
                      _busy ? null : () => _signOut(clearDeviceData: true),
                  child: Text(
                    l10n.settingsAccountSignOutClear,
                    style: GoogleFonts.nunito(
                      color: AppColors.mutedText(brightness),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('auth_sync_now'),
                  onPressed: _busy
                      ? null
                      : () async {
                          setState(() => _busy = true);
                          final result =
                              await ref.read(syncActionsProvider).syncIfSignedIn();
                          setState(() {
                            _busy = false;
                            _status = result.ok
                                ? _syncStatusMessage(
                                    l10n,
                                    result,
                                    prefix: l10n.settingsAccountSynced,
                                  )
                                : l10n.syncFailedWithError('${result.error}');
                          });
                        },
                  child: Text(l10n.settingsAccountSyncNow),
                ),
                const SizedBox(height: 16),
                TextButton(
                  key: const Key('auth_delete_account'),
                  onPressed: _busy ? null : _deleteAccount,
                  child: Text(
                    l10n.settingsAccountDeleteLink,
                    style: GoogleFonts.nunito(
                      color: AppColors.bloomDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              if (_status != null) ...[
                const SizedBox(height: 12),
                Text(
                  _status!,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.mutedText(brightness),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
