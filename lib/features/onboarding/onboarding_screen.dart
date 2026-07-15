import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'providers/onboarding_providers.dart';

enum _OnboardingStep { welcome, journey, details }

enum _JourneyChoice { none, pregnant, babyHere }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _OnboardingStep _step = _OnboardingStep.welcome;
  _JourneyChoice _journey = _JourneyChoice.none;
  DateTime? _dueDate;
  DateTime? _birthDate;
  final _babyNameController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _babyNameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _busy = true);
    try {
      if (_journey == _JourneyChoice.pregnant && _dueDate != null) {
        await ref.read(onboardingActionsProvider).savePregnancyDueDate(_dueDate!);
      }
      if (_journey == _JourneyChoice.babyHere) {
        await ref.read(onboardingActionsProvider).saveBabyProfile(
              name: _babyNameController.text,
              birthDate: _birthDate,
            );
      }
      await ref.read(onboardingActionsProvider).complete();
      if (!mounted) return;
      context.go(AppRoutes.today);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 120)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 320)),
      helpText: 'Select due date',
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
      helpText: 'Birth date',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_step != _OnboardingStep.welcome)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('onboarding_back'),
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _step = switch (_step) {
                                _OnboardingStep.details =>
                                  _OnboardingStep.journey,
                                _ => _OnboardingStep.welcome,
                              };
                            }),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                ),
              Expanded(
                child: switch (_step) {
                  _OnboardingStep.welcome => _welcomeStep(isDark),
                  _OnboardingStep.journey => _journeyStep(isDark),
                  _OnboardingStep.details => _detailsStep(isDark),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcomeStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          'BloomDue',
          style: GoogleFonts.fraunces(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.cream : AppColors.bark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Grow with confidence.',
          style: GoogleFonts.nunito(
            fontSize: 18,
            color: AppColors.bloom,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Calm baby care from bump to toddler. '
          'Two taps at 3am — no guilt, no paywall.',
          style: GoogleFonts.nunito(
            fontSize: 16,
            height: 1.5,
            color: AppColors.barkSoft,
          ),
        ),
        const Spacer(),
        FilledButton(
          key: const Key('onboarding_get_started'),
          onPressed: _busy
              ? null
              : () => setState(() => _step = _OnboardingStep.journey),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.sage,
            foregroundColor: AppColors.cream,
            minimumSize: const Size.fromHeight(52),
          ),
          child: const Text('Get started'),
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('onboarding_skip'),
          onPressed: _busy ? null : _finish,
          child: const Text('Skip for now'),
        ),
      ],
    );
  }

  Widget _journeyStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Where are you?',
          style: GoogleFonts.fraunces(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.cream : AppColors.bark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We will tailor your home screen. You can change this anytime.',
          style: GoogleFonts.nunito(color: AppColors.barkSoft, height: 1.45),
        ),
        const SizedBox(height: 32),
        _journeyCard(
          key: const Key('onboarding_journey_pregnant'),
          title: 'Still expecting',
          subtitle: 'Track due date, kicks, and appointments',
          selected: _journey == _JourneyChoice.pregnant,
          onTap: () => setState(() => _journey = _JourneyChoice.pregnant),
        ),
        const SizedBox(height: 12),
        _journeyCard(
          key: const Key('onboarding_journey_baby'),
          title: 'Baby is here',
          subtitle: 'Log feeds, diapers, and sleep',
          selected: _journey == _JourneyChoice.babyHere,
          onTap: () => setState(() => _journey = _JourneyChoice.babyHere),
        ),
        const Spacer(),
        FilledButton(
          key: const Key('onboarding_continue'),
          onPressed: _journey == _JourneyChoice.none || _busy
              ? null
              : () => setState(() => _step = _OnboardingStep.details),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.bloom,
            foregroundColor: AppColors.cream,
            minimumSize: const Size.fromHeight(52),
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _detailsStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          _journey == _JourneyChoice.pregnant
              ? 'When is baby due?'
              : 'Tell us about baby',
          style: GoogleFonts.fraunces(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.cream : AppColors.bark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Optional — skip anything you do not know yet.',
          style: GoogleFonts.nunito(color: AppColors.barkSoft),
        ),
        const SizedBox(height: 28),
        if (_journey == _JourneyChoice.pregnant) ...[
          OutlinedButton(
            key: const Key('onboarding_pick_due_date'),
            onPressed: _pickDueDate,
            child: Text(
              _dueDate == null
                  ? 'Pick due date'
                  : 'Due ${_dueDate!.toLocal().toString().split(' ').first}',
            ),
          ),
        ] else ...[
          TextField(
            key: const Key('onboarding_baby_name'),
            controller: _babyNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Baby name',
              hintText: 'Baby',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            key: const Key('onboarding_pick_birth_date'),
            onPressed: _pickBirthDate,
            child: Text(
              _birthDate == null
                  ? 'Birth date (optional)'
                  : 'Born ${_birthDate!.toLocal().toString().split(' ').first}',
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Sign in later in Settings to sync with a partner.',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: AppColors.barkSoft,
          ),
        ),
        const Spacer(),
        FilledButton(
          key: const Key('onboarding_finish'),
          onPressed: _busy ? null : _finish,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.sage,
            foregroundColor: AppColors.cream,
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(_busy ? 'Saving…' : 'Start logging'),
        ),
      ],
    );
  }

  Widget _journeyCard({
    required Key key,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      key: key,
      color: selected ? AppColors.sage.withValues(alpha: 0.12) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.sage
                  : AppColors.bark.withValues(alpha: 0.08),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.nunito(color: AppColors.barkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}