import 'enums.dart';

/// A finished match as stored in Match History.
class MatchRecord {
  const MatchRecord({
    required this.id,
    required this.redName,
    required this.blueName,
    required this.redScore,
    required this.blueScore,
    required this.winner,
    required this.reason,
    required this.dateTime,
    required this.durationSeconds,
  });

  final String id;
  final String redName;
  final String blueName;
  final int redScore;
  final int blueScore;
  final Side winner;
  final WinReason reason;
  final DateTime dateTime;
  final int durationSeconds;

  String get winnerName => winner == Side.red ? redName : blueName;

  Map<String, dynamic> toJson() => {
    'id': id,
    'redName': redName,
    'blueName': blueName,
    'redScore': redScore,
    'blueScore': blueScore,
    'winner': winner.name,
    'reason': reason.name,
    'dateTime': dateTime.toIso8601String(),
    'durationSeconds': durationSeconds,
  };

  static MatchRecord fromJson(Map<String, dynamic> j) => MatchRecord(
    id: j['id'] as String,
    redName: j['redName'] as String,
    blueName: j['blueName'] as String,
    redScore: j['redScore'] as int,
    blueScore: j['blueScore'] as int,
    winner: Side.values.byName(j['winner'] as String),
    reason: WinReason.values.byName(j['reason'] as String),
    dateTime: DateTime.parse(j['dateTime'] as String),
    durationSeconds: j['durationSeconds'] as int,
  );
}
