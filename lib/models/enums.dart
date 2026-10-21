enum Side {
  red,
  blue;

  Side get opposite => this == Side.red ? Side.blue : Side.red;
}

/// WKF Kumite scoring actions.
enum ScoreType {
  yuko(1),
  wazaAri(2),
  ippon(3);

  const ScoreType(this.points);
  final int points;
}

/// Penalty ladder (WKF structure). Order matters: index = severity.
enum PenaltyLevel { none, chui1, chui2, chui3, hansokuChui, hansoku }

enum WinReason { points, senshu, ippon, wazaAri, hantei, hansoku, pointGap }

enum MatchStatus { ready, running, paused, hanteiPending, finished }
