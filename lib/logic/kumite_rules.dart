import '../models/enums.dart';

/// All tunable rule values live here, separate from the engine and the UI,
/// so they can be updated when the official rules change.
///
/// NOTE: these defaults were written without access to the official WKF
/// document in this build environment. Verify them against the current WKF
/// Kumite Competition Rules before official use.
class KumiteRules {
  const KumiteRules({
    this.pointGapToWin = 8,
    this.warningSeconds = 15,
    this.senshuLostAtPenalty = PenaltyLevel.chui2,
  });

  /// A lead of this many points ends the match immediately (0 = disabled).
  final int pointGapToWin;

  /// Audible warning when this many seconds remain.
  final int warningSeconds;

  /// Senshu stops being active once its holder reaches this penalty level.
  final PenaltyLevel senshuLostAtPenalty;
}
