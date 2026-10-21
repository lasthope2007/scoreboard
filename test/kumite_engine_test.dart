import 'package:flutter_test/flutter_test.dart';
import 'package:kumite_scoreboard/logic/kumite_engine.dart';
import 'package:kumite_scoreboard/models/enums.dart';
import 'package:kumite_scoreboard/models/fighter.dart';
import 'package:kumite_scoreboard/models/kumite_match.dart';

KumiteMatch match(Fighter red, Fighter blue, {bool gap = true}) => KumiteMatch(
  red: red,
  blue: blue,
  durationSeconds: 120,
  remainingMs: 0,
  pointGapEnabled: gap,
);

void main() {
  const engine = KumiteEngine();
  const r = Fighter(name: 'R');
  const b = Fighter(name: 'B');

  test('higher score wins', () {
    final o = engine.decideAtTimeOver(
      match(r.copyWith(yuko: 3), b.copyWith(yuko: 2)),
    );
    expect(o.winner, Side.red);
    expect(o.reason, WinReason.points);
  });

  test('equal score: active senshu wins before tie-break', () {
    final m = match(
      r.copyWith(yuko: 2, hasSenshu: true),
      b.copyWith(wazaAri: 1),
    );
    final o = engine.decideAtTimeOver(m);
    expect(o.winner, Side.red);
    expect(o.reason, WinReason.senshu);
  });

  test('equal score, no senshu: more IPPON wins', () {
    // red 3 = 1 ippon, blue 3 = 3 yuko
    final m = match(r.copyWith(ippon: 1), b.copyWith(yuko: 3));
    final o = engine.decideAtTimeOver(m);
    expect(o.winner, Side.red);
    expect(o.reason, WinReason.ippon);
  });

  test('equal score and IPPON: more WAZA-ARI wins', () {
    // red 2 = 1 waza-ari, blue 2 = 2 yuko, ippon equal (0)
    final m = match(r.copyWith(wazaAri: 1), b.copyWith(yuko: 2));
    final o = engine.decideAtTimeOver(m);
    expect(o.winner, Side.red);
    expect(o.reason, WinReason.wazaAri);
  });

  test('everything equal: HANTEI', () {
    final o = engine.decideAtTimeOver(
      match(r.copyWith(yuko: 1), b.copyWith(yuko: 1)),
    );
    expect(o.needsHantei, true);
    expect(o.winner, isNull);
    expect(engine.decideAtTimeOver(match(r, b)).needsHantei, true);
  });

  test('senshu lost after Chui 2 falls through to tie-break', () {
    final m = match(
      r.copyWith(yuko: 3, hasSenshu: true, penalty: PenaltyLevel.chui2),
      b.copyWith(ippon: 1),
    );
    final o = engine.decideAtTimeOver(m);
    expect(o.winner, Side.blue);
    expect(o.reason, WinReason.ippon);
  });

  test('hansoku ends match for opponent', () {
    final o = engine.checkImmediate(
      match(r.copyWith(penalty: PenaltyLevel.hansoku), b),
    );
    expect(o.winner, Side.blue);
    expect(o.reason, WinReason.hansoku);
  });

  test('8-point gap ends match, and can be disabled', () {
    final big = match(r.copyWith(ippon: 3), b.copyWith(yuko: 1)); // 9 vs 1
    expect(engine.checkImmediate(big).reason, WinReason.pointGap);
    final off = match(r.copyWith(ippon: 3), b.copyWith(yuko: 1), gap: false);
    expect(engine.checkImmediate(off).isDecided, false);
  });

  test('tie-break is not used while scores differ', () {
    final m = match(r.copyWith(yuko: 4), b.copyWith(ippon: 1));
    expect(engine.decideAtTimeOver(m).reason, WinReason.points);
  });
}
