import '../models/enums.dart';
import '../models/kumite_match.dart';
import 'kumite_rules.dart';

class MatchOutcome {
  const MatchOutcome.none() : winner = null, reason = null, needsHantei = false;
  const MatchOutcome.win(Side this.winner, WinReason this.reason)
    : needsHantei = false;
  const MatchOutcome.hantei()
    : winner = null,
      reason = WinReason.hantei,
      needsHantei = true;

  final Side? winner;
  final WinReason? reason;
  final bool needsHantei;

  bool get isDecided => winner != null;
}

/// Pure rules logic. No Flutter imports, no timers, no UI.
class KumiteEngine {
  const KumiteEngine([this.rules = const KumiteRules()]);

  final KumiteRules rules;

  /// Senshu counts only while its holder is below the cancelling penalty.
  bool isSenshuActive(KumiteMatch m, Side side) {
    final f = m.fighter(side);
    return f.hasSenshu && f.penalty.index < rules.senshuLostAtPenalty.index;
  }

  Side? activeSenshuHolder(KumiteMatch m) {
    for (final s in Side.values) {
      if (isSenshuActive(m, s)) return s;
    }
    return null;
  }

  /// Outcomes that end the match regardless of the clock.
  MatchOutcome checkImmediate(KumiteMatch m) {
    for (final side in Side.values) {
      if (m.fighter(side).penalty == PenaltyLevel.hansoku) {
        return MatchOutcome.win(side.opposite, WinReason.hansoku);
      }
    }
    if (m.pointGapEnabled && rules.pointGapToWin > 0) {
      final diff = m.red.points - m.blue.points;
      if (diff.abs() >= rules.pointGapToWin) {
        return MatchOutcome.win(
          diff > 0 ? Side.red : Side.blue,
          WinReason.pointGap,
        );
      }
    }
    return const MatchOutcome.none();
  }

  /// Decision when time is over (or the match is ended by the operator).
  ///
  /// Order: immediate outcomes → points → Senshu →
  /// tie-break (IPPON count → WAZA-ARI count) → HANTEI.
  /// The tie-break only runs when scores are equal and nobody has active Senshu.
  MatchOutcome decideAtTimeOver(KumiteMatch m) {
    final immediate = checkImmediate(m);
    if (immediate.isDecided) return immediate;

    final diff = m.red.points - m.blue.points;
    if (diff != 0) {
      return MatchOutcome.win(
        diff > 0 ? Side.red : Side.blue,
        WinReason.points,
      );
    }

    final senshu = activeSenshuHolder(m);
    if (senshu != null) return MatchOutcome.win(senshu, WinReason.senshu);

    final ipponDiff = m.red.ippon - m.blue.ippon;
    if (ipponDiff != 0) {
      return MatchOutcome.win(
        ipponDiff > 0 ? Side.red : Side.blue,
        WinReason.ippon,
      );
    }

    final wazaDiff = m.red.wazaAri - m.blue.wazaAri;
    if (wazaDiff != 0) {
      return MatchOutcome.win(
        wazaDiff > 0 ? Side.red : Side.blue,
        WinReason.wazaAri,
      );
    }

    return const MatchOutcome.hantei();
  }
}
