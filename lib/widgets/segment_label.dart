import 'package:flutter/material.dart';

/// A segmented button label that shrinks instead of wrapping.
///
/// Segments split the row evenly, so a translated word longer than its share
/// wraps and breaks mid-word ("Greutat" / "e" on the growth chart in Romanian).
/// Scaling down keeps it on one line, and it only kicks in when the text does
/// not fit, so English and short labels are untouched.
class SegmentLabel extends StatelessWidget {
  const SegmentLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, maxLines: 1, softWrap: false),
    );
  }
}
