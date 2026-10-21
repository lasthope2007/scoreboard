import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/feedback_service.dart';
import 'state/history_controller.dart';
import 'state/match_controller.dart';
import 'state/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Landscape only (both directions, so the phone can be held either way).
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsController(prefs)..load();
  final history = HistoryController(prefs)..load();
  final match = MatchController(
    history: history,
    feedback: FeedbackService(settings),
  );

  runApp(KumiteApp(settings: settings, history: history, match: match));
}
