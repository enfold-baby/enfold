import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/database/app_database.dart';
import '../../baby/providers/baby_profile_providers.dart';

class BabyProfileSection extends ConsumerStatefulWidget {
  const BabyProfileSection({super.key});

  @override
  ConsumerState<BabyProfileSection> createState() => _BabyProfileSectionState();
}

class _BabyProfileSectionState extends ConsumerState<BabyProfileSection> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  bool _isPreemie = false;
  bool _dirty = false;
  bool _saving = false;
  String? _status;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncFromBaby(Baby baby) {
    if (_dirty) return;
    _nameController.text = baby.name;
    _birthDate = baby.birthDate;
    _isPreemie = baby.isPreemie;
  }

  Future<void> _save() async {
    final l10n = AppL10n.of(context);
    setState(() {
      _saving = true;
      _status = null;
    });
    try {
      await ref.read(babyProfileActionsProvider).updateProfile(
            name: _nameController.text,
            birthDate: _birthDate,
            isPreemie: _isPreemie,
          );
      setState(() {
        _dirty = false;
        _status = l10n.settingsBabySaved;
      });
    } catch (_) {
      setState(() => _status = l10n.settingsBabySaveFailed);
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 4)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: AppL10n.of(context).settingsBabyBirthDateLabel,
    );
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _dirty = true;
      _status = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppL10n.of(context);
    final babyAsync = ref.watch(activeBabyProvider);
    final dateFormat = DateFormat.yMMMMd();

    return babyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (baby) {
        _syncFromBaby(baby);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                l10n.settingsBabyTitle,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                l10n.settingsBabySubtitle,
                style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('baby_name'),
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l10n.settingsBabyNameLabel,
                      hintText: l10n.commonBabyFallbackName,
                    ),
                    onChanged: (_) => setState(() {
                      _dirty = true;
                      _status = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    key: const Key('baby_birth_date'),
                    onPressed: _pickBirthDate,
                    child: Text(
                      _birthDate == null
                          ? l10n.settingsBabySetBirthDate
                          : l10n.settingsBabyBorn(
                              dateFormat.format(_birthDate!),
                            ),
                    ),
                  ),
                  if (_birthDate != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        key: const Key('baby_clear_birth_date'),
                        onPressed: () => setState(() {
                          _birthDate = null;
                          _dirty = true;
                          _status = null;
                        }),
                        child: Text(l10n.settingsBabyClearBirthDate),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SwitchListTile(
                    key: const Key('baby_preemie'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.settingsBabyPreterm,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      l10n.settingsBabyPretermSubtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.mutedText(brightness),
                      ),
                    ),
                    value: _isPreemie,
                    onChanged: (value) => setState(() {
                      _isPreemie = value;
                      _dirty = true;
                      _status = null;
                    }),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    key: const Key('baby_save_profile'),
                    onPressed: _saving || !_dirty ? null : _save,
                    child: Text(
                      _saving ? l10n.settingsBabySaving : l10n.settingsBabySave,
                    ),
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
          ],
        );
      },
    );
  }
}