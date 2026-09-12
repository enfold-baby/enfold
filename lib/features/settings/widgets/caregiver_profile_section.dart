import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/auth/display_name.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/auth/auth_providers.dart';

/// How this person identifies when logging care (shown on partner devices).
const caregiverRoleOptions = <String>[
  'Mom',
  'Dad',
  'Partner',
  'Grandma',
  'Grandpa',
  'Caregiver',
  'Other',
];

/// Compose server `display_name` from optional role + name.
String composeCaregiverDisplayName({String? role, String? name}) {
  final r = role?.trim() ?? '';
  final n = name?.trim() ?? '';
  if (r.isNotEmpty && n.isNotEmpty) {
    if (r == 'Other') return n;
    return '$r · $n';
  }
  if (r.isNotEmpty && r != 'Other') return r;
  if (n.isNotEmpty) return n;
  return '';
}

/// Split a stored display name back into role + free-text name when possible.
({String? role, String name}) parseCaregiverDisplayName(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return (role: null, name: '');

  for (final role in caregiverRoleOptions) {
    if (role == 'Other') continue;
    if (value == role) return (role: role, name: '');
    final prefix = '$role · ';
    if (value.startsWith(prefix)) {
      return (role: role, name: value.substring(prefix.length).trim());
    }
  }
  return (role: 'Other', name: value);
}

class CaregiverProfileSection extends ConsumerStatefulWidget {
  const CaregiverProfileSection({super.key});

  @override
  ConsumerState<CaregiverProfileSection> createState() =>
      _CaregiverProfileSectionState();
}

class _CaregiverProfileSectionState
    extends ConsumerState<CaregiverProfileSection> {
  final _nameController = TextEditingController();
  String? _role;
  bool _dirty = false;
  bool _saving = false;
  String? _status;
  String? _hydratedForUserId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _hydrateFromSession() {
    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null) return;
    // Don't clobber in-progress edits for the same user.
    if (_hydratedForUserId == session.user.id) return;

    final parsed = parseCaregiverDisplayName(session.user.displayName);
    _role = parsed.role;
    _nameController.text = parsed.name;
    _hydratedForUserId = session.user.id;
    _dirty = false;
  }

  Future<void> _save() async {
    final session = ref.read(authSessionProvider).valueOrNull;
    if (session == null) {
      setState(() => _status = 'Sign in to save your profile.');
      return;
    }

    final displayName = composeCaregiverDisplayName(
      role: _role,
      name: _nameController.text,
    );

    setState(() {
      _saving = true;
      _status = null;
    });
    try {
      await ref
          .read(authSessionProvider.notifier)
          .updateDisplayName(displayName);
      setState(() {
        _dirty = false;
        _status = displayName.isEmpty
            ? 'Profile cleared. Logs will use your email name.'
            : 'Saved as “$displayName”. New logs will show this.';
      });
    } catch (_) {
      setState(() => _status = 'Could not save profile. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session == null) return const SizedBox.shrink();

    // Keep fields in sync after sign-in / reload without fighting edits.
    if (_hydratedForUserId != session.user.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(_hydrateFromSession);
      });
    }

    final preview = composeCaregiverDisplayName(
      role: _role,
      name: _nameController.text,
    );
    final fallback = authorLabelForUser(session.user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Your caregiver profile',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            'So partners see who logged each feed, diaper, or sleep.',
            style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'I am…',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                key: const Key('caregiver_role_chips'),
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final role in caregiverRoleOptions)
                    ChoiceChip(
                      key: Key('caregiver_role_$role'),
                      label: Text(role),
                      selected: _role == role,
                      onSelected: (selected) {
                        setState(() {
                          _role = selected ? role : null;
                          _dirty = true;
                          _status = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('caregiver_name'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name (optional)',
                  hintText: 'e.g. Ana',
                ),
                onChanged: (_) => setState(() {
                  _dirty = true;
                  _status = null;
                }),
              ),
              const SizedBox(height: 12),
              Text(
                'On logs: ${preview.isEmpty ? fallback : preview}',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent(brightness),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('caregiver_profile_save'),
                onPressed: _saving || !_dirty ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Save profile'),
              ),
              if (_status != null) ...[
                const SizedBox(height: 10),
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
