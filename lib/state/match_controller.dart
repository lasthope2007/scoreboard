import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../logic/kumite_engine.dart';
import '../models/enums.dart';
import '../models/fighter.dart';
import '../models/kumite_match.dart';
import '../models/match_record.dart';
import '../services/feedback_service.dart';
import 'history_controller.dart';

/// Owns the live match: timer + operator actions. All rule decisions are
/// delegated to [KumiteEngine].
///
/// The clock is derived from a wall-clock end time (not by counting ticks),
/// so it stays correct if the app is paused, rebuilt or sent to background.
class MatchController extends ChangeNotifier {
  MatchController({
    required this.history,
    required this.feedback,
    this.engine = const KumiteEngine(),
  });

  final HistoryController history;
  final FeedbackService feedback;
  final KumiteEngine engine;

  KumiteMatch? _match;
  KumiteMatch? get match => _match;

  Timer? _ticker;
  DateTime? _endAt;
  DateTime? _lastAccrue;
  bool _warned = false;
  bool _saved = false;

  int get _warnMs => engine.rules.warningSeconds * 1000;

  bool get canAct {
    final s = _match?.status;
    return s == MatchStatus.running || s == MatchStatus.paused;
  }

  bool get canUndo => canAct && (_match?.scoreLog.isNotEmpty ?? false);

  // ---------------------------------------------------------------- setup

  void startMatch({
    required String redName,
    required String blueName,
    required int durationSeconds,
    required bool pointGapEnabled,
  }) {
    _cancelTicker();
    _warned = false;
    _saved = false;
    _match = KumiteMatch(
      red: Fighter(name: redName),
      blue: Fighter(name: blueName),
      durationSeconds: durationSeconds,
      remainingMs: durationSeconds * 1000,
      pointGapEnabled: pointGapEnabled,
    );
    notifyListeners();
  }

  /// Stops the clock without touching history (match left unfinished).
  void abandon() {
    _cancelTicker();
    _match = null;
  }

  // ---------------------------------------------------------------- timer

  void start() {
    final m = _match;
    if (m == null) return;
    if (m.status != MatchStatus.ready && m.status != MatchStatus.paused) return;
    if (m.remainingMs <= 0) return;
    final now = DateTime.now();
    _endAt = now.add(Duration(milliseconds: m.remainingMs));
    _lastAccrue = now;
    if (m.remainingMs <= _warnMs) _warned = true;
    _match = m.copyWith(status: MatchStatus.running);
    _startTicker();
    notifyListeners();
  }

  void pause() {
    final m = _match;
    if (m == null || m.status != MatchStatus.running) return;
    _tick(); // bring remaining time up to date
    final current = _match!;
    if (current.status != MatchStatus.running) return; // finished on this tick
    _cancelTicker();
    _match = current.copyWith(status: MatchStatus.paused);
    notifyListeners();
  }

  void toggleRun() {
    final m = _match;
    if (m == null) return;
    if (m.status == MatchStatus.running) {
      pause();
    } else {
      start();
    }
  }

  void reset() {
    final m = _match;
    if (m == null) return;
    if (m.status != MatchStatus.ready && m.status != MatchStatus.paused) return;
    _cancelTicker();
    _warned = false;
    _match = m.copyWith(
      remainingMs: m.durationSeconds * 1000,
      elapsedMs: 0,
      status: MatchStatus.ready,
    );
    notifyListeners();
  }

  void adjustTime(int deltaSeconds) {
    final m = _match;
    if (m == null) return;
    if (m.status == MatchStatus.hanteiPending ||
        m.status == MatchStatus.finished) {
      return;
    }
    if (m.status == MatchStatus.running) _tick();
    final cur = _match!;
    if (cur.status == MatchStatus.finished) return;
    final next = math.min(
      kMaxDurationSeconds * 1000,
      math.max(0, cur.remainingMs + deltaSeconds * 1000),
    );
    if (next > _warnMs) _warned = false;
    _match = cur.copyWith(remainingMs: next);
    if (cur.status == MatchStatus.running) {
      _endAt = DateTime.now().add(Duration(milliseconds: next));
      if (next == 0) {
        _onTimeOver();
        return;
      }
    }
    notifyListeners();
  }

  /// Call when the app returns to the foreground.
  void syncTime() => _tick();

  void _startTicker() {
    _ticker?.cancel(); // never more than one timer running
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    final m = _match;
    if (m == null || m.status != MatchStatus.running) return;
    final now = DateTime.now();
    final remaining = math.max(0, _endAt!.difference(now).inMilliseconds);
    final elapsed = m.elapsedMs + now.difference(_lastAccrue!).inMilliseconds;
    _lastAccrue = now;
    _match = m.copyWith(remainingMs: remaining, elapsedMs: elapsed);

    if (remaining == 0) {
      _onTimeOver();
      return;
    }
    if (!_warned && remaining <= _warnMs) {
      _warned = true;
      feedback.warning();
    }
    // Only repaint when the visible second changes.
    if ((m.remainingMs + 999) ~/ 1000 != (remaining + 999) ~/ 1000) {
      notifyListeners();
    }
  }

  void _onTimeOver() {
    feedback.end();
    _resolve(timeOver: true);
  }

  // -------------------------------------------------------------- actions

  void addScore(Side side, ScoreType type) {
    final m = _match;
    if (m == null || !canAct) return;
    feedback.tap();
    _match = m
        .withFighter(side, m.fighter(side).withScoreDelta(type, 1))
        .copyWith(scoreLog: [...m.scoreLog, ScoreEntry(side, type)]);
    _resolve(timeOver: false);
  }

  void undo() {
    final m = _match;
    if (m == null || !canUndo) return;
    final last = m.scoreLog.last;
    _match = m
        .withFighter(
          last.side,
          m.fighter(last.side).withScoreDelta(last.type, -1),
        )
        .copyWith(scoreLog: m.scoreLog.sublist(0, m.scoreLog.length - 1));
    feedback.tap();
    notifyListeners();
  }

  void changePenalty(Side side, int delta) {
    final m = _match;
    if (m == null || !canAct) return;
    final f = m.fighter(side);
    final idx = (f.penalty.index + delta).clamp(
      0,
      PenaltyLevel.values.length - 1,
    );
    if (idx == f.penalty.index) return;
    feedback.tap();
    _match = m.withFighter(side, f.copyWith(penalty: PenaltyLevel.values[idx]));
    _resolve(timeOver: false);
  }

  void toggleSenshu(Side side) {
    final m = _match;
    if (m == null || !canAct) return;
    feedback.tap();
    final had = m.fighter(side).hasSenshu;
    var next = m.withFighter(side, m.fighter(side).copyWith(hasSenshu: !had));
    if (!had) {
      // Only one fighter can hold Senshu.
      next = next.withFighter(
        side.opposite,
        next.fighter(side.opposite).copyWith(hasSenshu: false),
      );
    }
    _match = next;
    notifyListeners();
  }

  /// Operator ends the match before the clock reaches zero.
  void endNow() {
    if (!canAct) return;
    _resolve(timeOver: true);
  }

  void chooseHantei(Side winner) {
    final m = _match;
    if (m == null || m.status != MatchStatus.hanteiPending) return;
    _match = m.copyWith(
      status: MatchStatus.finished,
      winner: winner,
      reason: WinReason.hantei,
    );
    _saveRecord();
    notifyListeners();
  }

  /// Back out of the Hantei screen (e.g. the match was ended by mistake).
  void cancelHantei() {
    final m = _match;
    if (m == null || m.status != MatchStatus.hanteiPending) return;
    _match = m.copyWith(status: MatchStatus.paused);
    notifyListeners();
  }

  // ---------------------------------------------------------------- core

  void _resolve({required bool timeOver}) {
    final m = _match!;
    final outcome = timeOver
        ? engine.decideAtTimeOver(m)
        : engine.checkImmediate(m);
    if (outcome.needsHantei) {
      _cancelTicker();
      _match = m.copyWith(status: MatchStatus.hanteiPending);
    } else if (outcome.isDecided) {
      _cancelTicker();
      _match = m.copyWith(
        status: MatchStatus.finished,
        winner: outcome.winner,
        reason: outcome.reason,
      );
      _saveRecord();
    }
    notifyListeners();
  }

  void _saveRecord() {
    final m = _match!;
    if (_saved || m.winner == null || m.reason == null) return;
    _saved = true;
    final now = DateTime.now();
    history.add(
      MatchRecord(
        id: now.microsecondsSinceEpoch.toString(),
        redName: m.red.name,
        blueName: m.blue.name,
        redScore: m.red.points,
        blueScore: m.blue.points,
        winner: m.winner!,
        reason: m.reason!,
        dateTime: now,
        durationSeconds: (m.elapsedMs / 1000).round(),
      ),
    );
  }

  @override
  void dispose() {
    _cancelTicker();
    super.dispose();
  }
}
