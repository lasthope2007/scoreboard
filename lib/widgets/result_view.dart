import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/enums.dart';
import '../models/kumite_match.dart';
import '../theme/app_theme.dart';
import 'big_button.dart';

/// Shown when the match is finished: big winner, final score, reason.
class ResultView extends StatelessWidget {
  const ResultView({
    super.key,
    required this.match,
    required this.onNewMatch,
    required this.onHome,
  });

  final KumiteMatch match;
  final VoidCallback onNewMatch;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final winner = match.winner!;
    final color = AppColors.side(winner);
    final scheme = Theme.of(context).colorScheme;

    Widget score(Side s) => Column(
      children: [
        Text(
          l.sideName(s),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.side(s),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            '${match.fighter(s).points}',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );

    final left = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l.t('winner'),
          style: TextStyle(
            fontSize: 22,
            letterSpacing: 6,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            match.fighter(winner).name,
            maxLines: 1,
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        Text(
          l.sideName(winner),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.onSurface.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            l.winnerBy(match.reason!),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );

    final right = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l.t('final_score'),
          style: TextStyle(
            fontSize: 14,
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          textDirection: TextDirection.ltr, // Red left, Blue right
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            score(Side.red),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Text('–', style: TextStyle(fontSize: 40)),
            ),
            score(Side.blue),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: BigButton(
                label: l.t('new_match'),
                icon: Icons.add,
                color: scheme.onSurface,
                foreground: scheme.surface,
                onPressed: onNewMatch,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BigButton(
                label: l.t('back_home'),
                icon: Icons.home_outlined,
                onPressed: onHome,
              ),
            ),
          ],
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.35), scheme.surface],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Row(
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 32),
                  SizedBox(width: 380, child: right),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
