import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bloom_brand_mark.dart';
import '../../widgets/bloom_illustrations.dart';
import '../../widgets/bloom_surface.dart';
import '../pregnancy/expecting_date_bounds.dart';
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
        await ref
            .read(onboardingActionsProvider)
            .savePregnancyDueDate(_dueDate!);
      }
      if (_journey == _JourneyChoice.babyHere) {
        await ref
            .read(onboardingActionsProvider)
            .saveBabyProfile(
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
    final today = calendarToday();
    // Expecting: no past due dates (local calendar day).
    final initial = today.add(const Duration(days: 120));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 320)),
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

  bool get _wideWelcome {
    final size = MediaQuery.sizeOf(context);
    return size.shortestSide >= 600 && size.width / size.height >= 1.15;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final landscapeSplit = _wideWelcome;
            final maxWidth = landscapeSplit
                ? constraints.maxWidth
                : (constraints.maxWidth >= 600 ? 560.0 : constraints.maxWidth);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                    maxWidth: maxWidth,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _OnboardingHeader(
                          step: _step,
                          busy: _busy,
                          onBack: _goBack,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.04, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                            child: switch (_step) {
                              _OnboardingStep.welcome => _welcomeStep(),
                              _OnboardingStep.journey => _journeyStep(),
                              _OnboardingStep.details => _detailsStep(),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _goBack() {
    if (_busy) return;
    setState(() {
      _step = switch (_step) {
        _OnboardingStep.details => _OnboardingStep.journey,
        _ => _OnboardingStep.welcome,
      };
    });
  }

  Widget _welcomeStep() {
    final wide = _wideWelcome;
    return Column(
      key: const ValueKey(_OnboardingStep.welcome),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        if (wide)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: _welcomeHero(fit: BoxFit.contain),
                ),
                const SizedBox(width: 28),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _welcomeCopy(),
                      const Spacer(),
                      _welcomeActions(),
                    ],
                  ),
                ),
              ],
            ),
          )
        else ...[
          _welcomeHero(fit: BoxFit.cover, aspectRatio: 1.45),
          const SizedBox(height: 20),
          _welcomeCopy(),
          const Spacer(),
          const SizedBox(height: 16),
          _welcomeActions(),
        ],
      ],
    );
  }

  Widget _welcomeCopy() {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enfold', style: theme.textTheme.displayLarge),
        const SizedBox(height: 8),
        Text(
          'Grow with confidence.',
          style: theme.textTheme.titleMedium?.copyWith(color: AppColors.bloom),
        ),
        const SizedBox(height: 8),
        Text(
          'Calm baby care from bump to toddler. Quick when you need it, '
          'reassuring when you do not know what comes next.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.mutedText(brightness),
          ),
        ),
      ],
    );
  }

  Widget _welcomeActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          key: const Key('onboarding_get_started'),
          onPressed: _busy
              ? null
              : () => setState(() => _step = _OnboardingStep.journey),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
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

  Widget _welcomeHero({
    required BoxFit fit,
    double? aspectRatio,
  }) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    Widget hero = Container(
      key: const Key('onboarding_welcome_hero'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.nightElevated, AppColors.nightCard]
              : [AppColors.sageMist, AppColors.bloomMist],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? AppColors.nightLine
              : Colors.white.withValues(alpha: 0.9),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(31),
              child: Image.asset(
                BloomIllustrations.familyCare,
                fit: fit,
                alignment: const Alignment(0, 0.12),
                color: isDark
                    ? AppColors.nightCard.withValues(alpha: 0.72)
                    : null,
                colorBlendMode: isDark ? BlendMode.multiply : null,
                excludeFromSemantics: true,
              ),
            ),
          ),
          const Positioned(top: 14, left: 14, child: BloomBrandMark(size: 46)),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface(
                    brightness,
                  ).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'CALM CARE · DAY & NIGHT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.mutedText(brightness),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (aspectRatio == null) return hero;
    // Not a LayoutBuilder: this sits under IntrinsicHeight, which cannot
    // measure one (a debug assertion every frame, and a short measure in
    // release that can clip the welcome step on small phones).
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 180, maxHeight: 300),
      child: AspectRatio(aspectRatio: aspectRatio, child: hero),
    );
  }

  Widget _journeyStep() {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Column(
      key: const ValueKey(_OnboardingStep.journey),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(
          'Where are you\nin the journey?',
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Choose what feels closest today. You can change this anytime.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.mutedText(brightness),
          ),
        ),
        const SizedBox(height: 28),
        _journeyCard(
          key: const Key('onboarding_journey_pregnant'),
          title: 'Still expecting',
          subtitle: 'Due date, kicks, appointments, and gentle guidance',
          illustration: BloomIllustrations.pregnancyJourney,
          illustrationAlignment: Alignment.centerRight,
          accent: AppColors.bloom,
          selected: _journey == _JourneyChoice.pregnant,
          onTap: () => setState(() => _journey = _JourneyChoice.pregnant),
        ),
        const SizedBox(height: 14),
        _journeyCard(
          key: const Key('onboarding_journey_baby'),
          title: 'Baby is here',
          subtitle: 'Feeds, diapers, sleep, growth, and shared care',
          illustration: BloomIllustrations.familyCare,
          illustrationAlignment: Alignment.center,
          accent: AppColors.sage,
          selected: _journey == _JourneyChoice.babyHere,
          onTap: () => setState(() => _journey = _JourneyChoice.babyHere),
        ),
        const Spacer(),
        const SizedBox(height: 28),
        FilledButton(
          key: const Key('onboarding_continue'),
          onPressed: _journey == _JourneyChoice.none || _busy
              ? null
              : () => setState(() => _step = _OnboardingStep.details),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _detailsStep() {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final expecting = _journey == _JourneyChoice.pregnant;

    return Column(
      key: const ValueKey(_OnboardingStep.details),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: expecting
                ? AppColors.bloom.withValues(alpha: 0.14)
                : AppColors.sage.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(
            expecting
                ? Icons.event_available_outlined
                : Icons.waving_hand_outlined,
            color: expecting
                ? AppColors.readableInk(AppColors.bloom, brightness)
                : AppColors.accent(brightness),
            size: 30,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          expecting ? 'When is baby due?' : 'A little about baby',
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Everything here is optional. Add only what feels useful.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.mutedText(brightness),
          ),
        ),
        const SizedBox(height: 28),
        BloomSurface(
          color: AppColors.softSurface(brightness),
          child: expecting
              ? OutlinedButton.icon(
                  key: const Key('onboarding_pick_due_date'),
                  onPressed: _pickDueDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    _dueDate == null
                        ? 'Pick due date'
                        : 'Due ${DateFormat.yMMMMd().format(_dueDate!)}',
                  ),
                )
              : Column(
                  children: [
                    TextField(
                      key: const Key('onboarding_baby_name'),
                      controller: _babyNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Baby name',
                        hintText: 'Baby',
                        prefixIcon: Icon(Icons.face_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      key: const Key('onboarding_pick_birth_date'),
                      onPressed: _pickBirthDate,
                      icon: const Icon(Icons.cake_outlined),
                      label: Text(
                        _birthDate == null
                            ? 'Birth date (optional)'
                            : 'Born ${DateFormat.yMMMMd().format(_birthDate!)}',
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline,
              size: 18,
              color: AppColors.accent(brightness),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your care log starts offline. Sign in later to share with a partner.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedText(brightness),
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        const SizedBox(height: 28),
        FilledButton(
          key: const Key('onboarding_finish'),
          onPressed: _busy ? null : _finish,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          child: Text(_busy ? 'Saving…' : 'Start caring'),
        ),
      ],
    );
  }

  Widget _journeyCard({
    required Key key,
    required String title,
    required String subtitle,
    required String illustration,
    required Alignment illustrationAlignment,
    required Color accent,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    return BloomSurface(
      key: key,
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      padding: const EdgeInsets.all(12),
      color: selected
          ? accent.withValues(alpha: isDark ? 0.18 : 0.09)
          : AppColors.cardSurface(brightness),
      borderColor: selected
          ? accent
          : (isDark
                ? AppColors.nightLine
                : AppColors.bark.withValues(alpha: 0.08)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 82,
              height: 92,
              child: Image.asset(
                illustration,
                fit: BoxFit.cover,
                alignment: illustrationAlignment,
                color: isDark
                    ? AppColors.nightCard.withValues(alpha: 0.75)
                    : null,
                colorBlendMode: isDark ? BlendMode.multiply : null,
                excludeFromSemantics: true,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText(brightness),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: selected ? accent : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? accent : AppColors.mutedText(brightness),
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 17)
                : null,
          ),
        ],
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.step,
    required this.busy,
    required this.onBack,
  });

  final _OnboardingStep step;
  final bool busy;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    if (step == _OnboardingStep.welcome) {
      return Row(
        children: [
          const BloomBrandMark(size: 34, showBackdrop: false),
          const SizedBox(width: 8),
          Text('Enfold', style: Theme.of(context).textTheme.titleMedium),
        ],
      );
    }

    return Row(
      children: [
        IconButton.filledTonal(
          key: const Key('onboarding_back'),
          onPressed: busy ? null : onBack,
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
        ),
        const Spacer(),
        for (var index = 0; index < 2; index++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: index == step.index - 1 ? 30 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index <= step.index - 1
                  ? AppColors.sage
                  : AppColors.sage.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          if (index == 0) const SizedBox(width: 7),
        ],
      ],
    );
  }
}
