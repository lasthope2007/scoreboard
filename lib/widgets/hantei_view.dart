import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/enums.dart';
import '../models/kumite_match.dart';
import '../theme/app_theme.dart';
import 'big_button.dart';

/// Scores, IPPON and WAZA-ARI are all equal and nobody has Senshu:
/// the operator records the judges' HANTEI decision.
class HanteiView extends StatelessWidget {
  const HanteiView({
    super.key,
    required this.match,
    required this.onChoose,
    required this.onBack,
  });

  final KumiteMatch match;
  final ValueChanged<Side> onChoose;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.t('hantei_title'),
                        style: const TextStyle(
                          fontSize: 48,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.t('hantei_sub'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final s in Side.values) ...[
                        BigButton(
                          label: l
                              .t('wins')
                              .replaceAll('{n}', match.fighter(s).name),
                          color: AppColors.side(s),
                          foreground: Colors.white,
                          height: 72,
                          fontSize: 24,
                          onPressed: () => onChoose(s),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextButton(onPressed: onBack, child: Text(l.t('back'))),
                    ],
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
