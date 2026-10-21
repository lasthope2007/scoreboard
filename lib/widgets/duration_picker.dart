import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/format.dart';

/// Chips for common durations plus a -/+ stepper (10 s steps).
class DurationPicker extends StatelessWidget {
  const DurationPicker({
    super.key,
    required this.seconds,
    required this.onChanged,
  });

  final int seconds;
  final ValueChanged<int> onChanged;

  static const _presets = [60, 90, 120, 180];

  void _set(int v) =>
      onChanged(v.clamp(kMinDurationSeconds, kMaxDurationSeconds));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              iconSize: 28,
              onPressed: () => _set(seconds - 10),
              icon: const Icon(Icons.remove),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  formatSeconds(seconds),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            IconButton.filledTonal(
              iconSize: 28,
              onPressed: () => _set(seconds + 10),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            for (final p in _presets)
              ChoiceChip(
                label: Text(formatSeconds(p)),
                selected: seconds == p,
                onSelected: (_) => _set(p),
              ),
          ],
        ),
      ],
    );
  }
}
