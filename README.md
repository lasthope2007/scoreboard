# Kumite Scoreboard (Flutter, Android, offline)

Landscape only. English is the default language; Persian (RTL) is available in Settings.
Red is always on the left and Blue on the right, in both languages.

## Setup (first time)

Platform folders are not included; generate them once:

    flutter create --platforms=android --project-name kumite_scoreboard .
    python3 tool/lock_landscape.py     # optional: lock landscape in the manifest too
    flutter pub get
    flutter analyze
    flutter test
    flutter run            # or: flutter build apk --release

Requires Flutter 3.27+ (Dart 3.4+). No INTERNET permission is needed in release builds.

## Structure

    lib/
      models/        Fighter, KumiteMatch, MatchRecord, enums
      logic/         kumite_rules.dart (tunable values), kumite_engine.dart (pure rules, no Flutter)
      state/         MatchController (clock + operator actions), Settings, History
      services/      sound + vibration
      screens/       home, new match, match, history, settings
      widgets/       fighter panel, timer, penalty indicator, result / hantei views
      theme/ localization/ core/

## Rules implemented (lib/logic)

- Scores: Yuko 1, Waza-ari 2, Ippon 3. Undo removes the last score.
- Immediate end: Hansoku (opponent wins); optional 8-point lead (toggle in Settings).
- At time over: higher score wins; if equal, active Senshu wins; otherwise
  more IPPON, then more WAZA-ARI, then HANTEI (operator picks the judges' winner).
- Senshu is manual (one holder) and becomes inactive when its holder reaches Chui 2.
- Penalties never add points automatically. Verify these values against the
  current official WKF rules: they live in `kumite_rules.dart`.

## Build the APK without installing Flutter

Push this project to GitHub. The workflow in `.github/workflows/build-apk.yml`
builds the release APK automatically: open the Actions tab, pick the latest
run, and download `kumite-scoreboard-apk` from Artifacts. (Release builds are
signed with the debug key, which is fine for installing on your own phone.)
