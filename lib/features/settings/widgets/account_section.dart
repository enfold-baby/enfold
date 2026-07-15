import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/api/api_exception.dart';
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

  String _requestCodeErrorMessage(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 422) {
        return 'Enter a valid email address.';
      }
      return 'Could not send code (${error.message}).';
    }
    return 'Could not send code. Check your connection and try again.';
  }

  Future<void> _requestCode() async {
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
        _status = 'Check your email for a 6-digit code.';
      });
    } catch (e) {
      setState(() => _status = _requestCodeErrorMessage(e));
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await ref.read(authSessionProvider.notifier).verifyMagicCode(
            email: _emailController.text,
            code: _codeController.text,
          );
      final result = await ref.read(syncActionsProvider).syncIfSignedIn();
      setState(() {
        _status = result.ok
            ? _syncStatusMessage(result, prefix: 'Signed in')
            : 'Signed in, but sync will retry (${result.error}).';
      });
    } catch (e) {
      setState(() => _status = 'Invalid or expired code.');
    } finally {
      setState(() => _busy = false);
    }
  }

  String _syncStatusMessage(SyncResult result, {required String prefix}) {
    final parts = <String>[prefix];
    if (result.pushed > 0) parts.add('${result.pushed} pushed');
    if (result.pulled > 0) parts.add('${result.pulled} from partner');
    if (parts.length == 1) parts.add('up to date');
    return '${parts.join(' · ')}.';
  }

  Future<void> _signOut() async {
    await ref.read(authSessionProvider.notifier).signOut();
    setState(() {
      _codeSent = false;
      _devCode = null;
      _status = null;
      _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final sessionAsync = ref.watch(authSessionProvider);
    final session = sessionAsync.valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Account & sync',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            session == null
                ? 'Sign in to back up logs and share with a partner.'
                : 'Signed in as ${session.user.email}',
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
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('auth_send_code'),
                  onPressed: _busy ? null : _requestCode,
                  child: Text(_codeSent ? 'Resend code' : 'Send sign-in code'),
                ),
                if (_codeSent) ...[
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('auth_code'),
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '6-digit code',
                    ),
                  ),
                  if (_devCode != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Dev code: $_devCode',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.sageDeep,
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
                    child: const Text('Verify & sync'),
                  ),
                ],
              ] else ...[
                OutlinedButton(
                  key: const Key('auth_sign_out'),
                  onPressed: _busy ? null : _signOut,
                  child: const Text('Sign out'),
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
                                ? _syncStatusMessage(result, prefix: 'Synced')
                                : 'Sync failed: ${result.error}';
                          });
                        },
                  child: const Text('Sync now'),
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