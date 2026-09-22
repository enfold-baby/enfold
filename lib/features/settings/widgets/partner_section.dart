import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/api/api_exception.dart';
import '../../../services/api/family_models.dart';
import '../../../services/auth/account_switch_service.dart';
import '../../../services/auth/auth_providers.dart';
import '../../../services/sync/sync_providers.dart';

final familyInfoProvider = FutureProvider<FamilyInfo?>((ref) async {
  final session = ref.watch(authSessionProvider).valueOrNull;
  if (session == null) return null;

  try {
    return await ref.read(apiClientProvider).getFamily(session.token);
  } on ApiException catch (e) {
    if (e.statusCode == 404) return null;
    rethrow;
  }
});

class PartnerSection extends ConsumerStatefulWidget {
  const PartnerSection({super.key});

  @override
  ConsumerState<PartnerSection> createState() => _PartnerSectionState();
}

class _PartnerSectionState extends ConsumerState<PartnerSection> {
  final _codeController = TextEditingController();
  String? _status;
  bool _busy = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showFeedback(String message, {bool error = false}) {
    if (!mounted) return;
    setState(() => _status = message);
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Colors.red.shade800 : null,
        ),
      );
  }

  Future<void> _createInvite() async {
    final l10n = AppL10n.of(context);
    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null) {
      _showFeedback(l10n.settingsPartnerSignInFirst, error: true);
      return;
    }

    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final invite =
          await ref.read(apiClientProvider).createFamilyInvite(session.token);
      await Clipboard.setData(ClipboardData(text: invite.code));
      ref.invalidate(familyInfoProvider);
      _showFeedback(l10n.settingsPartnerInviteCopied(invite.code));
    } on ApiException catch (e) {
      _showFeedback(_messageForApiError(l10n, e), error: true);
    } catch (_) {
      _showFeedback(l10n.settingsPartnerInviteFailed, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _joinFamily() async {
    final l10n = AppL10n.of(context);
    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null) return;

    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await ref.read(apiClientProvider).joinFamily(
            token: session.token,
            code: code,
          );
      // Rebind to the host family's baby (never create a second child).
      ref.invalidate(familyInfoProvider);
      final joined = await ref.read(syncActionsProvider).syncAfterFamilyJoin();
      final syncResult = joined.result;
      final babyLabel = joined.babyName;
      final shareBit = babyLabel != null && babyLabel.isNotEmpty
          ? l10n.settingsPartnerJoinedForBaby(babyLabel)
          : '';
      final pulledBit = syncResult.pulled > 0
          ? l10n.settingsPartnerJoinedPulled(syncResult.pulled)
          : '';
      _showFeedback(
        syncResult.ok
            ? l10n.settingsPartnerJoined(shareBit, pulledBit)
            : l10n.settingsPartnerJoinedSyncRetry('${syncResult.error}'),
      );
      _codeController.clear();
    } on ApiException catch (e) {
      _showFeedback(_messageForApiError(l10n, e), error: true);
    } catch (_) {
      _showFeedback(l10n.settingsPartnerJoinFailed, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leaveFamily() async {
    final l10n = AppL10n.of(context);
    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('partner_leave_dialog'),
        title: Text(
          l10n.settingsPartnerLeaveTitle,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        content: Text(
          l10n.settingsPartnerLeaveBody,
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const Key('partner_leave_confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.settingsPartnerLeaveConfirm),
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
      await ref.read(apiClientProvider).leaveFamily(session.token);
      // Drop partner-synced local rows; family keeps server data.
      await ref.read(accountSwitchServiceProvider).clearLocalCareData();
      ref.invalidate(familyInfoProvider);
      _showFeedback(l10n.settingsPartnerLeft);
    } on ApiException catch (e) {
      _showFeedback(_messageForApiError(l10n, e), error: true);
    } catch (_) {
      _showFeedback(l10n.settingsPartnerLeaveFailed, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _messageForApiError(AppL10n l10n, ApiException e) {
    if (e.statusCode == 404) {
      // Distinct copy: join uses 404 for bad codes; create used to 404 when
      // the families router was missing on the API.
      return e.message.contains('Invite') || e.message.contains('code')
          ? e.message
          : l10n.settingsPartnerApiUnreachable(e.message);
    }
    return e.message;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppL10n.of(context);
    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session == null) return const SizedBox.shrink();

    final familyAsync = ref.watch(familyInfoProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            l10n.settingsPartnerTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            l10n.settingsPartnerSubtitle,
            style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: familyAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            ),
            error: (_, __) => Text(
              l10n.settingsPartnerLoadFailed,
              style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
            ),
            data: (family) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (family != null && family.members.length > 1) ...[
                  Text(
                    l10n.settingsPartnerSharedWith(
                      family.members.length - 1,
                    ),
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent(brightness),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...family.members.map(
                    (member) => Text(
                      member.email,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.mutedText(brightness),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('partner_leave_family'),
                    onPressed: _busy ? null : _leaveFamily,
                    icon: const Icon(Icons.logout_outlined),
                    label: Text(l10n.settingsPartnerLeaveButton),
                  ),
                  const SizedBox(height: 16),
                ],
                if (family?.inviteCode != null) ...[
                  Container(
                    key: const Key('partner_invite_code'),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.softSurface(brightness),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settingsPartnerYourInviteCode,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent(brightness),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          family!.inviteCode!,
                          style: GoogleFonts.fraunces(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('partner_copy_invite'),
                    onPressed: _busy
                        ? null
                        : () async {
                            await Clipboard.setData(
                              ClipboardData(text: family.inviteCode!),
                            );
                            setState(
                              () => _status =
                                  l10n.settingsPartnerInviteCodeCopied,
                            );
                          },
                    icon: const Icon(Icons.copy_outlined),
                    label: Text(l10n.settingsPartnerCopyInvite),
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.icon(
                  key: const Key('partner_create_invite'),
                  onPressed: _busy ? null : _createInvite,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.bloom,
                    foregroundColor: AppColors.cream,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.person_add_outlined),
                  label: Text(l10n.settingsPartnerCreateInvite),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.settingsPartnerHaveACode,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('partner_join_code'),
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.settingsPartnerJoinCodeLabel,
                    hintText: 'BLOOM42',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('partner_join'),
                  onPressed: _busy ? null : _joinFamily,
                  child: Text(l10n.settingsPartnerJoinButton),
                ),
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
        ),
      ],
    );
  }
}