import 'enums.dart';
import 'fighter.dart';

class ScoreEntry {
  const ScoreEntry(this.side, this.type);
  final Side side;
  final ScoreType type;
}

class KumiteMatch {
  const KumiteMatch({
    required this.red,
    required this.blue,
    required this.durationSeconds,
    required this.remainingMs,
    this.pointGapEnabled = true,
    this.status = MatchStatus.ready,
    this.winner,
    this.reason,
    this.scoreLog = const [],
    this.elapsedMs = 0,
  });

  final Fighter red;
  final Fighter blue;
  final int durationSeconds;
  final int remainingMs;
  final bool pointGapEnabled;
  final MatchStatus status;
  final Side? winner;
  final WinReason? reason;
  final List<ScoreEntry> scoreLog;
  final int elapsedMs;

  Fighter fighter(Side side) => side == Side.red ? red : blue;

  KumiteMatch withFighter(Side side, Fighter f) =>
      side == Side.red ? copyWith(red: f) : copyWith(blue: f);

  KumiteMatch copyWith({
    Fighter? red,
    Fighter? blue,
    int? remainingMs,
    MatchStatus? status,
    Side? winner,
    WinReason? reason,
    List<ScoreEntry>? scoreLog,
    int? elapsedMs,
  }) {
    return KumiteMatch(
      red: red ?? this.red,
      blue: blue ?? this.blue,
      durationSeconds: durationSeconds,
      remainingMs: remainingMs ?? this.remainingMs,
      pointGapEnabled: pointGapEnabled,
      status: status ?? this.status,
      winner: winner ?? this.winner,
      reason: reason ?? this.reason,
      scoreLog: scoreLog ?? this.scoreLog,
      elapsedMs: elapsedMs ?? this.elapsedMs,
    );
  }
}
