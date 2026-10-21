import 'enums.dart';

class Fighter {
  const Fighter({
    required this.name,
    this.yuko = 0,
    this.wazaAri = 0,
    this.ippon = 0,
    this.penalty = PenaltyLevel.none,
    this.hasSenshu = false,
  });

  final String name;
  final int yuko;
  final int wazaAri;
  final int ippon;
  final PenaltyLevel penalty;
  final bool hasSenshu;

  int get points => yuko * 1 + wazaAri * 2 + ippon * 3;

  int count(ScoreType type) => switch (type) {
    ScoreType.yuko => yuko,
    ScoreType.wazaAri => wazaAri,
    ScoreType.ippon => ippon,
  };

  Fighter withScoreDelta(ScoreType type, int delta) {
    final next = (count(type) + delta).clamp(0, 999);
    return switch (type) {
      ScoreType.yuko => copyWith(yuko: next),
      ScoreType.wazaAri => copyWith(wazaAri: next),
      ScoreType.ippon => copyWith(ippon: next),
    };
  }

  Fighter copyWith({
    String? name,
    int? yuko,
    int? wazaAri,
    int? ippon,
    PenaltyLevel? penalty,
    bool? hasSenshu,
  }) {
    return Fighter(
      name: name ?? this.name,
      yuko: yuko ?? this.yuko,
      wazaAri: wazaAri ?? this.wazaAri,
      ippon: ippon ?? this.ippon,
      penalty: penalty ?? this.penalty,
      hasSenshu: hasSenshu ?? this.hasSenshu,
    );
  }
}
