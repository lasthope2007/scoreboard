import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/app_localizations.dart';
import '../models/enums.dart';
import '../state/match_controller.dart';
import '../state/settings_controller.dart';
import '../widgets/big_button.dart';
import '../widgets/duration_picker.dart';
import 'match_screen.dart';

/// Creates a match from the user's current default settings.
/// Used by Quick Match (immediately) and New Match (after editing).
void launchMatch(
  BuildContext context, {
  String? redName,
  String? blueName,
  int? durationSeconds,
  bool replace = false,
}) {
  final settings = context.read<SettingsController>();
  final l = context.l10n;
  String pick(String? typed, String saved, Side side) {
    final t = (typed ?? saved).trim();
    return t.isEmpty ? l.sideName(side) : t;
  }

  context.read<MatchController>().startMatch(
    redName: pick(redName, settings.defaultRedName, Side.red),
    blueName: pick(blueName, settings.defaultBlueName, Side.blue),
    durationSeconds: durationSeconds ?? settings.durationSeconds,
    pointGapEnabled: settings.pointGapRule,
  );
  final route = MaterialPageRoute<void>(builder: (_) => const MatchScreen());
  if (replace) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).push(route);
  }
}

class NewMatchScreen extends StatefulWidget {
  const NewMatchScreen({super.key});

  @override
  State<NewMatchScreen> createState() => _NewMatchScreenState();
}

class _NewMatchScreenState extends State<NewMatchScreen> {
  late final TextEditingController _red;
  late final TextEditingController _blue;
  late int _duration;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsController>();
    _red = TextEditingController(text: s.defaultRedName);
    _blue = TextEditingController(text: s.defaultBlueName);
    _duration = s.durationSeconds;
  }

  @override
  void dispose() {
    _red.dispose();
    _blue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.t('new_match'))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _NameField(
                          controller: _red,
                          label: l.t('red_name'),
                          hint: l.sideName(Side.red),
                          color: const Color(0xFFE5383B),
                        ),
                        const SizedBox(height: 14),
                        _NameField(
                          controller: _blue,
                          label: l.t('blue_name'),
                          hint: l.sideName(Side.blue),
                          color: const Color(0xFF2F80ED),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l.t('duration'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DurationPicker(
                          seconds: _duration,
                          onChanged: (v) => setState(() => _duration = v),
                        ),
                        const SizedBox(height: 24),
                        BigButton(
                          label: l.t('start_match'),
                          icon: Icons.sports_martial_arts,
                          height: 64,
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.onSurface,
                          foreground: Theme.of(context).colorScheme.surface,
                          onPressed: () => launchMatch(
                            context,
                            redName: _red.text,
                            blueName: _blue.text,
                            durationSeconds: _duration,
                            replace: true,
                          ),
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

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.color,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      maxLength: 24,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        prefixIcon: Icon(Icons.circle, color: color, size: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
