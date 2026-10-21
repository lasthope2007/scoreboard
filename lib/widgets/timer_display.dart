import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../core/format.dart';
import '../models/enums.dart';
import '../theme/app_theme.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.remainingMs,
    required this.status,
    required this.warningMs,
  });

  final int remainingMs;
  final MatchStatus status;
  final int warningMs;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final warning = remainingMs <= warningMs && status != MatchStatus.ready;
    final color = remainingMs == 0
        ? AppColors.red
        : warning
        ? AppColors.amber
        : scheme.onSurface;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          formatClock(remainingMs),
          style: TextStyle(
            fontSize: 220,
            height: 1.0,
            fontWeight: FontWeight.w800,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
