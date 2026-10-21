import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';
import 'history_screen.dart';
import 'new_match_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    final quick = _Tile(
      title: l.t('quick_match'),
      subtitle: l.t('quick_match_sub'),
      icon: Icons.bolt,
      primary: true,
      onTap: () => launchMatch(context),
    );
    final others = [
      _Tile(
        title: l.t('new_match'),
        icon: Icons.add_circle_outline,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewMatchScreen())),
      ),
      _Tile(
        title: l.t('history'),
        icon: Icons.history,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const HistoryScreen())),
      ),
      _Tile(
        title: l.t('settings'),
        icon: Icons.settings_outlined,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _Dot(AppColors.red),
                  const SizedBox(width: 10),
                  Text(
                    l.t('app_title'),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const _Dot(AppColors.blue),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Row(
                  children: [
                    Expanded(flex: 5, child: quick),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          for (var i = 0; i < others.length; i++) ...[
                            Expanded(child: others[i]),
                            if (i != others.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 14,
    height: 14,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.primary = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = primary ? scheme.onSurface : scheme.surface;
    final fg = primary ? scheme.surface : scheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: primary ? 56 : 32, color: fg),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: primary ? 34 : 20,
                          fontWeight: FontWeight.w900,
                          color: fg,
                        ),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 15,
                          color: fg.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
