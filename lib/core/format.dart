/// MM:SS from milliseconds. Rounds up so the display hits 00:00 only at 0.
String formatClock(int ms) {
  final totalSeconds = (ms + 999) ~/ 1000;
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String formatSeconds(int seconds) => formatClock(seconds * 1000);

String formatDateTime(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}';
}
