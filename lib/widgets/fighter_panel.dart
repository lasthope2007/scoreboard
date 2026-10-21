import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/enums.dart';
import '../models/fighter.dart';
import '../theme/app_theme.dart';
import 'penalty_indicator.dart';

class FighterPanel extends StatelessWidget {
  const FighterPanel({
    super.key,
    required this.side,
    required this.fighter,
    required this.senshuActive,
    required this.enabled,
    required this.onScore,
    required this.onSenshu,
    required this.onPenalty,
  });

  final Side side;
  final Fighter fighter;
  final bool senshuActive;
  final bool enabled;
  final ValueChanged<ScoreType> onScore;
  final VoidCallback onSenshu;
  final ValueChanged<int> onPenalty;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.side(side);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel(context, side),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: senshuActive ? 1.0 : 0.55),
          width: senshuActive ? 3 : 2,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, c) {
          // Buttons grow with the available height (phones → tablets).
          final btnHeight = (c.maxHeight * 0.17).clamp(46.0, 84.0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: side + name, Senshu toggle.
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fighter.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _SenshuChip(
                    has: fighter.hasSenshu,
                    active: senshuActive,
                    color: color,
                    onTap: enabled ? onSenshu : null,
                  ),
                ],
              ),
              // Score: the most important element, scales to the space left.
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${fighter.points}',
                        style: TextStyle(
                          fontSize: 260,
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                          color: scheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Counters per score type.
              Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final t in ScoreType.values)
                    _Counter(
                      label: context.l10n.scoreName(t),
                      value: fighter.count(t),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              // +1 / +2 / +3
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  for (final t in ScoreType.values) ...[
                    Expanded(
                      child: _ScoreButton(
                        type: t,
                        color: color,
                        height: btnHeight,
                        onTap: enabled ? () => onScore(t) : null,
                      ),
                    ),
                    if (t != ScoreType.ippon) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              // Penalties
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: context.tr('penalty_remove'),
                      onPressed: enabled && fighter.penalty != PenaltyLevel.none
                          ? () => onPenalty(-1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline, size: 30),
                    ),
                  ),
                  Expanded(child: PenaltyIndicator(level: fighter.penalty)),
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: context.tr('penalty_add'),
                      onPressed:
                          enabled && fighter.penalty != PenaltyLevel.hansoku
                          ? () => onPenalty(1)
                          : null,
                      icon: const Icon(Icons.add_circle_outline, size: 30),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
                child: Center(
                  child: Text(
                    context.l10n.penaltyName(fighter.penalty),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.65);
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: muted,
          ),
        ),
      ],
    );
  }
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({
    required this.type,
    required this.color,
    required this.height,
    required this.onTap,
  });

  final ScoreType type;
  final Color color;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.25),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        onPressed: onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+${type.points}',
                style: const TextStyle(
                  fontSize: 30,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                context.l10n.scoreName(type),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SenshuChip extends StatelessWidget {
  const _SenshuChip({
    required this.has,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final bool has;
  final bool active; // has && not cancelled by penalty
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lostByPenalty = has && !active;
    final bg = active ? color : scheme.onSurface.withValues(alpha: 0.08);
    final fg = active
        ? Colors.white
        : scheme.onSurface.withValues(alpha: lostByPenalty ? 0.55 : 0.7);
    return Tooltip(
      message: lostByPenalty ? context.tr('senshu_lost') : context.tr('senshu'),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  active ? Icons.star : Icons.star_border,
                  size: 16,
                  color: fg,
                ),
                const SizedBox(width: 4),
                Text(
                  context.tr('senshu'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: fg,
                    decoration: lostByPenalty
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
