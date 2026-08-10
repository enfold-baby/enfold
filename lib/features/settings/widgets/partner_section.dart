import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/api/api_exception.dart';
import '../../../services/api/family_models.dart';
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
    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null) {
      _showFeedback('Sign in first to create an invite.', error: true);
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
      _showFeedback('Invite code ${invite.code} copied.');
    } on ApiException catch (e) {
      _showFeedback(_messageForApiError(e), error: true);
    } catch (_) {
      _showFeedback('Could not create invite. Try again.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _joinFamily() async {
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
      ref.invalidate(familyInfoProvider);
      final syncResult = await ref.read(syncActionsProvider).syncIfSignedIn();
      setState(() {
        _codeController.clear();
        _status = syncResult.ok
            ? 'Joined family · pulled ${syncResult.pulled} partner logs.'
            : 'Joined family, but sync will retry (${syncResult.error}).';
      });
    } on ApiException catch (e) {
      setState(() => _status = _messageForApiError(e));
    } catch (_) {
      setState(() => _status = 'Could not join with that code.');
    } finally {
      setState(() => _busy = false);
    }
  }

  String _messageForApiError(ApiException e) {
    if (e.statusCode == 404) {
      // Distinct copy: join uses 404 for bad codes; create used to 404 when
      // the families router was missing on the API.
      return e.message.contains('Invite') || e.message.contains('code')
          ? e.message
          : 'Could not reach partner invites on the API (${e.message}). '
              'Is the backend up to date?';
    }
    return e.message;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session == null) return const SizedBox.shrink();

    final familyAsync = ref.watch(familyInfoProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Partner sharing',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            'Invite a co-parent to see the same today log.',
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
              'Could not load family info.',
              style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
            ),
            data: (family) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (family != null && family.members.length > 1) ...[
                  Text(
                    'Shared with ${family.members.length - 1} partner',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: AppColors.sage,
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
                  const SizedBox(height: 16),
                ],
                if (family?.inviteCode != null) ...[
                  Container(
                    key: const Key('partner_invite_code'),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.creamDeep,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your invite code',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            color: AppColors.sage,
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
                              () => _status = 'Invite code copied.',
                            );
                          },
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy invite code'),
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
                  label: const Text('Create invite code'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Have a code?',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('partner_join_code'),
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Partner invite code',
                    hintText: 'BLOOM42',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('partner_join'),
                  onPressed: _busy ? null : _joinFamily,
                  child: const Text('Join family'),
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