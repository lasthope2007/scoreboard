import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../theme/app_theme.dart';

/// Five steps: C1 C2 C3 HC H. Steps up to the current level are lit.
class PenaltyIndicator extends StatelessWidget {
  const PenaltyIndicator({super.key, required this.level});

  final PenaltyLevel level;

  static const _labels = ['C1', 'C2', 'C3', 'HC', 'H'];
  static const _colors = [
    AppColors.amber,
    AppColors.orange,
    Color(0xFFF4511E),
    AppColors.red,
    Color(0xFF8E24AA),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          for (var i = 0; i < 5; i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: level.index > i
                      ? _colors[i]
                      : scheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _labels[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: level.index > i
                          ? Colors.white
                          : scheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
