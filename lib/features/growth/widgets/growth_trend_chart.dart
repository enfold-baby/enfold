import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/units/growth_units.dart';
import '../models/growth_measurement_entry.dart';
import '../../../widgets/segment_label.dart';

enum GrowthChartMetric { weight, length, head }

class GrowthTrendChart extends StatefulWidget {
  const GrowthTrendChart({
    super.key,
    required this.measurements,
    required this.useImperial,
  });

  final List<GrowthMeasurementEntry> measurements;
  final bool useImperial;

  @override
  State<GrowthTrendChart> createState() => _GrowthTrendChartState();
}

class _GrowthTrendChartState extends State<GrowthTrendChart> {
  late Set<GrowthChartMetric> _metrics;
  final Map<GrowthChartMetric, int?> _selected = {};

  @override
  void initState() {
    super.initState();
    _metrics = {_preferredMetric(widget.measurements)};
  }

  @override
  void didUpdateWidget(covariant GrowthTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final metric in _metrics) {
      final points = _pointsFor(metric);
      final selected = _selected[metric];
      if (selected != null && selected >= points.length) {
        _selected[metric] = null;
      }
    }
  }

  static GrowthChartMetric _preferredMetric(
    List<GrowthMeasurementEntry> measurements,
  ) {
    if (measurements.any((m) => m.weightKg != null)) {
      return GrowthChartMetric.weight;
    }
    if (measurements.any((m) => m.lengthCm != null)) {
      return GrowthChartMetric.length;
    }
    if (measurements.any((m) => m.headCm != null)) {
      return GrowthChartMetric.head;
    }
    return GrowthChartMetric.weight;
  }

  List<({DateTime at, double value})> _pointsFor(GrowthChartMetric metric) {
    final points = <({DateTime at, double value})>[];
    for (final entry in widget.measurements) {
      final raw = switch (metric) {
        GrowthChartMetric.weight => entry.weightKg,
        GrowthChartMetric.length => entry.lengthCm,
        GrowthChartMetric.head => entry.headCm,
      };
      if (raw == null) continue;
      final value = switch (metric) {
        GrowthChartMetric.weight => widget.useImperial
            ? raw / GrowthUnits.kgPerLb
            : raw,
        GrowthChartMetric.length || GrowthChartMetric.head =>
          widget.useImperial ? raw / GrowthUnits.cmPerInch : raw,
      };
      points.add((at: entry.measuredAt, value: value));
    }
    points.sort((a, b) => a.at.compareTo(b.at));
    return points;
  }

  String _formatValue(GrowthChartMetric metric, double value) {
    switch (metric) {
      case GrowthChartMetric.weight:
        if (widget.useImperial) {
          final kg = value * GrowthUnits.kgPerLb;
          return GrowthUnits.formatWeightKg(kg, useImperial: true);
        }
        return GrowthUnits.formatWeightKg(value, useImperial: false);
      case GrowthChartMetric.length:
      case GrowthChartMetric.head:
        if (widget.useImperial) {
          return GrowthUnits.formatLengthCm(
            value * GrowthUnits.cmPerInch,
            useImperial: true,
          );
        }
        return GrowthUnits.formatLengthCm(value, useImperial: false);
    }
  }

  Color _metricColor(GrowthChartMetric metric) => switch (metric) {
        GrowthChartMetric.weight => AppColors.sage,
        GrowthChartMetric.length => AppColors.bloom,
        GrowthChartMetric.head => AppColors.sleepBlue,
      };

  String _metricLabel(AppL10n l10n, GrowthChartMetric metric) =>
      switch (metric) {
        GrowthChartMetric.weight => l10n.growthWeight,
        GrowthChartMetric.length => l10n.growthLength,
        GrowthChartMetric.head => l10n.growthHead,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppL10n.of(context);
    final selectedMetrics = GrowthChartMetric.values
        .where(_metrics.contains)
        .toList();

    return Container(
      key: const Key('growth_trend_chart'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.nightElevated : AppColors.creamDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.nightLine
              : AppColors.bark.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.growthTrendTitle,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.accent(
                isDark ? Brightness.dark : Brightness.light,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.growthTrendSubtitle,
            style: GoogleFonts.nunito(
              fontSize: 13,
              height: 1.4,
              color: AppColors.mutedText(Theme.of(context).brightness),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<GrowthChartMetric>(
            key: const Key('growth_chart_metric'),
            multiSelectionEnabled: true,
            emptySelectionAllowed: false,
            segments: [
              ButtonSegment(
                value: GrowthChartMetric.weight,
                label: SegmentLabel(l10n.growthWeight),
              ),
              ButtonSegment(
                value: GrowthChartMetric.length,
                label: SegmentLabel(l10n.growthLength),
              ),
              ButtonSegment(
                value: GrowthChartMetric.head,
                label: SegmentLabel(l10n.growthHead),
              ),
            ],
            selected: _metrics,
            onSelectionChanged: (selection) {
              setState(() {
                _metrics = selection;
                _selected.removeWhere((metric, _) => !selection.contains(metric));
              });
            },
          ),
          const SizedBox(height: 16),
          for (final metric in selectedMetrics) ...[
            if (selectedMetrics.length > 1) ...[
              Text(
                _metricLabel(l10n, metric),
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: _metricColor(metric),
                ),
              ),
              const SizedBox(height: 8),
            ],
            _seriesBlock(metric, isDark: isDark, compact: selectedMetrics.length > 1),
            if (metric != selectedMetrics.last) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _seriesBlock(
    GrowthChartMetric metric, {
    required bool isDark,
    required bool compact,
  }) {
    final points = _pointsFor(metric);
    final l10n = AppL10n.of(context);
    final dateFormat = DateFormat.MMMd();
    final color = _metricColor(metric);
    final selected = _selected[metric];

    if (points.isEmpty) {
      return Text(
        l10n.growthTrendEmpty(_metricLabel(l10n, metric).toLowerCase()),
        style: GoogleFonts.nunito(color: AppColors.mutedText(Theme.of(context).brightness), height: 1.45),
      );
    }
    if (points.length == 1) {
      return Text(
        l10n.growthTrendOnePoint(
          _formatValue(metric, points.first.value),
          dateFormat.format(points.first.at),
        ),
        style: GoogleFonts.nunito(color: AppColors.mutedText(Theme.of(context).brightness), height: 1.45),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: compact ? 132 : 168,
          child: _TrendPlot(
            points: points,
            color: color,
            selectedIndex: selected,
            isDark: isDark,
            onSelect: (index) => setState(() => _selected[metric] = index),
          ),
        ),
        if (selected != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.growthTrendSelected(
              _formatValue(metric, points[selected].value),
              DateFormat.yMMMd().format(points[selected].at),
            ),
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}

class _TrendPlot extends StatelessWidget {
  const _TrendPlot({
    required this.points,
    required this.color,
    required this.selectedIndex,
    required this.isDark,
    required this.onSelect,
  });

  final List<({DateTime at, double value})> points;
  final Color color;
  final int? selectedIndex;
  final bool isDark;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const left = 44.0;
        const right = 8.0;
        const top = 12.0;
        const bottom = 22.0;
        final plot = Size(
          constraints.maxWidth - left - right,
          constraints.maxHeight - top - bottom,
        );
        final minVal = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
        final maxVal = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
        final pad = maxVal == minVal ? (minVal.abs() * 0.08 + 0.2) : (maxVal - minVal) * 0.18;
        final yMin = minVal - pad;
        final yMax = maxVal + pad;
        final t0 = points.first.at.millisecondsSinceEpoch.toDouble();
        final t1 = points.last.at.millisecondsSinceEpoch.toDouble();
        final tSpan = t1 == t0 ? 1.0 : t1 - t0;

        Offset offsetFor(int i) {
          final p = points[i];
          final x = left + ((p.at.millisecondsSinceEpoch - t0) / tSpan) * plot.width;
          final y = top + (1 - (p.value - yMin) / (yMax - yMin)) * plot.height;
          return Offset(x, y);
        }

        final offsets = [for (var i = 0; i < points.length; i++) offsetFor(i)];

        return GestureDetector(
          onTapDown: (details) {
            var best = 0;
            var bestDist = double.infinity;
            for (var i = 0; i < offsets.length; i++) {
              final d = (offsets[i] - details.localPosition).distance;
              if (d < bestDist) {
                bestDist = d;
                best = i;
              }
            }
            if (bestDist < 36) onSelect(best);
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _TrendPainter(
              offsets: offsets,
              color: color,
              selectedIndex: selectedIndex,
              isDark: isDark,
              yLabels: [
                (y: yMax, text: _axisLabel(yMax)),
                (y: (yMin + yMax) / 2, text: _axisLabel((yMin + yMax) / 2)),
                (y: yMin, text: _axisLabel(yMin)),
              ],
              yMin: yMin,
              yMax: yMax,
              plotTop: top,
              plotHeight: plot.height,
              plotLeft: left,
              plotWidth: plot.width,
              firstDate: DateFormat.MMMd().format(points.first.at),
              lastDate: DateFormat.MMMd().format(points.last.at),
            ),
          ),
        );
      },
    );
  }

  String _axisLabel(double value) {
    final rounded = (value * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) return '${rounded.toInt()}';
    return '$rounded';
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.offsets,
    required this.color,
    required this.selectedIndex,
    required this.isDark,
    required this.yLabels,
    required this.yMin,
    required this.yMax,
    required this.plotTop,
    required this.plotHeight,
    required this.plotLeft,
    required this.plotWidth,
    required this.firstDate,
    required this.lastDate,
  });

  final List<Offset> offsets;
  final Color color;
  final int? selectedIndex;
  final bool isDark;
  final List<({double y, String text})> yLabels;
  final double yMin;
  final double yMax;
  final double plotTop;
  final double plotHeight;
  final double plotLeft;
  final double plotWidth;
  final String firstDate;
  final String lastDate;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (isDark ? AppColors.nightLine : AppColors.bark).withValues(
        alpha: 0.12,
      )
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromLTWH(plotLeft, plotTop, plotWidth, plotHeight),
      );

    for (final label in yLabels) {
      final y = plotTop + (1 - (label.y - yMin) / (yMax - yMin)) * plotHeight;
      canvas.drawLine(
        Offset(plotLeft, y),
        Offset(plotLeft + plotWidth, y),
        gridPaint,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: label.text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.mutedText(
              isDark ? Brightness.dark : Brightness.light,
            ),
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: plotLeft - 6);
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    if (offsets.length >= 2) {
      final line = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (final o in offsets.skip(1)) {
        line.lineTo(o.dx, o.dy);
      }
      final fill = Path.from(line)
        ..lineTo(offsets.last.dx, plotTop + plotHeight)
        ..lineTo(offsets.first.dx, plotTop + plotHeight)
        ..close();
      canvas.drawPath(fill, fillPaint);
      canvas.drawPath(line, linePaint);
    }

    for (var i = 0; i < offsets.length; i++) {
      final selected = selectedIndex == i;
      canvas.drawCircle(
        offsets[i],
        selected ? 6.5 : 4.5,
        Paint()..color = color,
      );
      canvas.drawCircle(
        offsets[i],
        selected ? 3.2 : 2.2,
        Paint()..color = isDark ? AppColors.nightElevated : AppColors.cream,
      );
    }

    final dateStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: AppColors.mutedText(isDark ? Brightness.dark : Brightness.light),
    );
    final first = TextPainter(
      text: TextSpan(text: firstDate, style: dateStyle),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final last = TextPainter(
      text: TextSpan(text: lastDate, style: dateStyle),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    first.paint(canvas, Offset(plotLeft, size.height - first.height));
    last.paint(
      canvas,
      Offset(plotLeft + plotWidth - last.width, size.height - last.height),
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.offsets != offsets ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.color != color ||
        oldDelegate.isDark != isDark;
  }
}
