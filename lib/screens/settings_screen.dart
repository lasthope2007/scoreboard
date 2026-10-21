import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/app_localizations.dart';
import '../state/settings_controller.dart';
import '../widgets/duration_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _red;
  late final TextEditingController _blue;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsController>();
    _red = TextEditingController(text: s.defaultRedName);
    _blue = TextEditingController(text: s.defaultBlueName);
  }

  @override
  void dispose() {
    _red.dispose();
    _blue.dispose();
    super.dispose();
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l.t('settings'))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _section(l.t('duration')),
                        DurationPicker(
                          seconds: s.durationSeconds,
                          onChanged: s.setDuration,
                        ),
                        _section(l.t('default_match')),
                        TextField(
                          controller: _red,
                          maxLength: 24,
                          decoration: InputDecoration(
                            labelText: l.t('red_name'),
                            counterText: '',
                          ),
                          onChanged: (v) => s.setDefaultNames(red: v),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _blue,
                          maxLength: 24,
                          decoration: InputDecoration(
                            labelText: l.t('blue_name'),
                            counterText: '',
                          ),
                          onChanged: (v) => s.setDefaultNames(blue: v),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l.t('point_gap_rule')),
                          value: s.pointGapRule,
                          onChanged: s.setPointGapRule,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l.t('sound')),
                          secondary: const Icon(Icons.volume_up_outlined),
                          value: s.soundOn,
                          onChanged: s.setSound,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l.t('vibration')),
                          secondary: const Icon(Icons.vibration),
                          value: s.vibrationOn,
                          onChanged: s.setVibration,
                        ),
                        _section(l.t('theme')),
                        SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: const Icon(Icons.dark_mode_outlined),
                              label: Text(l.t('theme_dark')),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: const Icon(Icons.light_mode_outlined),
                              label: Text(l.t('theme_light')),
                            ),
                          ],
                          selected: {s.themeMode},
                          onSelectionChanged: (v) => s.setThemeMode(v.first),
                        ),
                        _section(l.t('language')),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'en', label: Text('English')),
                            ButtonSegment(value: 'fa', label: Text('فارسی')),
                          ],
                          selected: {s.languageCode},
                          onSelectionChanged: (v) => s.setLanguage(v.first),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
