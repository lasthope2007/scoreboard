import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'localization/app_localizations.dart';
import 'screens/home_screen.dart';
import 'state/history_controller.dart';
import 'state/match_controller.dart';
import 'state/settings_controller.dart';
import 'theme/app_theme.dart';

class KumiteApp extends StatelessWidget {
  const KumiteApp({
    super.key,
    required this.settings,
    required this.history,
    required this.match,
  });

  final SettingsController settings;
  final HistoryController history;
  final MatchController match;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        ChangeNotifierProvider<HistoryController>.value(value: history),
        ChangeNotifierProvider<MatchController>.value(value: match),
      ],
      child: Consumer<SettingsController>(
        builder: (context, s, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kumite Scoreboard',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: s.themeMode,
          locale: s.locale, // 'fa' → Material applies RTL automatically
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
