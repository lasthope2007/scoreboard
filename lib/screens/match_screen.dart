import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../localization/app_localizations.dart';
import '../models/enums.dart';
import '../models/kumite_match.dart';
import '../state/match_controller.dart';
import '../widgets/big_button.dart';
import '../widgets/dialogs.dart';
import '../widgets/fighter_panel.dart';
import '../widgets/hantei_view.dart';
import '../widgets/result_view.dart';
import '../widgets/timer_display.dart';
import 'new_match_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with WidgetsBindingObserver {
  late final MatchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<MatchController>();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable(); // keep the screen on during a match
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _controller.syncTime();
  }

  Future<void> _leave() async {
    final m = _controller.match;
    final inProgress =
        m != null &&
        m.status != MatchStatus.finished &&
        m.status != MatchStatus.ready;
    if (inProgress &&
        !await confirmDialog(context, context.tr('confirm_leave'))) {
      return;
    }
    _controller.abandon();
    if (mounted) Navigator.of(context).pop();
  }

  void _home() {
    _controller.abandon();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _newMatch() {
    _controller.abandon();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const NewMatchScreen()),
    );
  }

  Future<void> _penalty(Side side, int delta) async {
    final m = _controller.match!;
    final next = m.fighter(side).penalty.index + delta;
    if (delta > 0 && next == PenaltyLevel.hansoku.index) {
      final ok = await confirmDialog(context, context.tr('confirm_hansoku'));
      if (!ok) return;
    }
    _controller.changePenalty(side, delta);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<MatchController>();
    final m = c.match;
    if (m == null) return const Scaffold(body: SizedBox.shrink());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        body: switch (m.status) {
          MatchStatus.finished => ResultView(
            match: m,
            onNewMatch: _newMatch,
            onHome: _home,
          ),
          MatchStatus.hanteiPending => HanteiView(
            match: m,
            onChoose: c.chooseHantei,
            onBack: c.cancelHantei,
          ),
          _ => SafeArea(
            child: _Board(
              match: m,
              controller: c,
              onLeave: _leave,
              onPenalty: _penalty,
            ),
          ),
        },
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({
    required this.match,
    required this.controller,
    required this.onLeave,
    required this.onPenalty,
  });

  final KumiteMatch match;
  final MatchController controller;
  final VoidCallback onLeave;
  final Future<void> Function(Side, int) onPenalty;

  @override
  Widget build(BuildContext context) {
    final engine = controller.engine;
    final enabled = controller.canAct;

    Widget panel(Side s) => FighterPanel(
      side: s,
      fighter: match.fighter(s),
      senshuActive: engine.isSenshuActive(match, s),
      enabled: enabled,
      onScore: (t) => controller.addScore(s, t),
      onSenshu: () => controller.toggleSenshu(s),
      onPenalty: (d) => onPenalty(s, d),
    );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, box) {
          final compact = box.maxHeight < 420; // small landscape phones
          final centerWidth = (box.maxWidth * 0.32).clamp(280.0, 440.0);
          return Row(
            textDirection:
                TextDirection.ltr, // Red left, Blue right in every language
            children: [
              Expanded(child: panel(Side.red)),
              const SizedBox(width: 8),
              SizedBox(
                width: centerWidth,
                child: Column(
                  children: [
                    Expanded(
                      child: _TimerBlock(
                        match: match,
                        controller: controller,
                        onLeave: onLeave,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Controls(
                      match: match,
                      controller: controller,
                      compact: compact,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: panel(Side.blue)),
            ],
          );
        },
      ),
    );
  }
}

class _TimerBlock extends StatelessWidget {
  const _TimerBlock({
    required this.match,
    required this.controller,
    required this.onLeave,
  });

  final KumiteMatch match;
  final MatchController controller;
  final VoidCallback onLeave;

  String _statusLabel(BuildContext context) => switch (match.status) {
    MatchStatus.ready => context.tr('status_ready'),
    MatchStatus.running => context.tr('status_running'),
    MatchStatus.paused => context.tr('status_paused'),
    _ => context.tr('status_final'),
  };

  /// One line: who wins if the clock ended right now.
  String _outlook(BuildContext context) {
    final l = context.l10n;
    if (match.status == MatchStatus.ready) return l.t('press_start');
    final o = controller.engine.decideAtTimeOver(match);
    final result = o.needsHantei
        ? l.t('hantei_now')
        : '${match.fighter(o.winner!).name} · ${l.reasonLabel(o.reason!)}';
    return '${l.t('now_leads')} $result';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.7);
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onLeave,
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _statusLabel(context),
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w800,
                      color: muted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // balances the back button
            ],
          ),
          Expanded(
            child: Center(
              child: TimerDisplay(
                remainingMs: match.remainingMs,
                status: match.status,
                warningMs: controller.engine.rules.warningSeconds * 1000,
              ),
            ),
          ),
          Text(
            _outlook(context),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.match,
    required this.controller,
    required this.compact,
  });

  final KumiteMatch match;
  final MatchController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final running = match.status == MatchStatus.running;
    final canStart = match.remainingMs > 0;
    final startLabel = running
        ? l.t('pause')
        : (match.status == MatchStatus.paused ? l.t('resume') : l.t('start'));
    final canReset =
        match.status == MatchStatus.ready || match.status == MatchStatus.paused;

    Widget adjust(String label, int delta) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: BigButton(
          label: label,
          height: compact ? 38 : 46,
          fontSize: 16,
          onPressed: () => controller.adjustTime(delta),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BigButton(
          label: startLabel,
          icon: running ? Icons.pause : Icons.play_arrow,
          height: compact ? 56 : 72,
          fontSize: 24,
          color: running
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Theme.of(context).colorScheme.onSurface,
          foreground: running
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.surface,
          onPressed: canStart ? controller.toggleRun : null,
        ),
        SizedBox(height: compact ? 6 : 8),
        Row(
          children: [
            Expanded(
              child: BigButton(
                label: l.t('undo'),
                icon: Icons.undo,
                height: compact ? 42 : 50,
                fontSize: 15,
                onPressed: controller.canUndo ? controller.undo : null,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: BigButton(
                label: l.t('reset'),
                icon: Icons.restart_alt,
                height: compact ? 42 : 50,
                fontSize: 15,
                onPressed: canReset
                    ? () async {
                        if (await confirmDialog(
                          context,
                          l.t('confirm_reset'),
                        )) {
                          controller.reset();
                        }
                      }
                    : null,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: BigButton(
                label: l.t('end_match'),
                icon: Icons.flag_outlined,
                height: compact ? 42 : 50,
                fontSize: 15,
                onPressed: controller.canAct
                    ? () async {
                        if (await confirmDialog(context, l.t('confirm_end'))) {
                          controller.endNow();
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              adjust('−10', -10),
              adjust('−1', -1),
              adjust('+1', 1),
              adjust('+10', 10),
            ],
          ),
        ),
      ],
    );
  }
}
