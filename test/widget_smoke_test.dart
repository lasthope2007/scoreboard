import 'package:flutter_test/flutter_test.dart';
import 'package:kumite_scoreboard/core/format.dart';

void main() {
  test('clock formatting', () {
    expect(formatClock(120000), '02:00');
    expect(formatClock(14001), '00:15'); // rounds up, hits 00:00 only at 0
    expect(formatClock(0), '00:00');
    expect(formatSeconds(75), '01:15');
  });
}
