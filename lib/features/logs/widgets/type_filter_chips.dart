import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../today/models/log_type.dart';

class HubTypeFilterChips extends StatelessWidget {
  const HubTypeFilterChips({
    super.key,
    required this.selected,
    required this.onAllTap,
    required this.onTypeTap,
  });

  final Set<LogType> selected;
  final VoidCallback onAllTap;
  final ValueChanged<LogType> onTypeTap;

  @override
  Widget build(BuildContext context) {
    final isAll = selected.isEmpty;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChip(
          key: const Key('filter_all_types'),
          label: 'All',
          selected: isAll,
          onTap: onAllTap,
        ),
        for (final type in LogType.values)
          _FilterChip(
            key: Key('filter_${type.formSegment}'),
            label: type.label,
            selected: !isAll && selected.contains(type),
            color: type.color,
            onTap: () => onTypeTap(type),
          ),
      ],
    );
  }
}

class DetailFilterChips<T> extends StatelessWidget {
  const DetailFilterChips({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<DetailFilterOption<T>> options;
  final T? selected;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: AppColors.accent(Theme.of(context).brightness),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              _FilterChip(
                label: option.label,
                selected: selected == option.value,
                onTap: () => onSelected(
                  selected == option.value ? null : option.value,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class DetailFilterOption<T> {
  const DetailFilterOption({required this.value, required this.label});

  final T value;
  final String label;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = color ?? AppColors.sage;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: GoogleFonts.nunito(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: selected
            ? AppColors.cream
            : AppColors.mutedText(
                isDark ? Brightness.dark : Brightness.light,
              ),
      ),
      selectedColor: activeColor,
      backgroundColor: isDark ? AppColors.nightElevated : AppColors.creamDeep,
      side: BorderSide(
        color: selected
            ? activeColor
            : (isDark
                ? AppColors.nightLine
                : AppColors.bark.withValues(alpha: 0.12)),
      ),
      showCheckmark: false,
    );
  }
}