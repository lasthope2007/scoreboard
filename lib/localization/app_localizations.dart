import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/enums.dart';

/// Lightweight offline localization (Persian + English), no code generation.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const delegate = _AppLocalizationsDelegate();
  static const supportedLocales = [Locale('fa'), Locale('en')];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  String t(String key) =>
      _strings[locale.languageCode]?[key] ?? _strings['en']![key] ?? key;

  String sideName(Side s) => t(s == Side.red ? 'red' : 'blue');

  String scoreName(ScoreType type) => switch (type) {
    ScoreType.yuko => t('yuko'),
    ScoreType.wazaAri => t('waza_ari'),
    ScoreType.ippon => t('ippon'),
  };

  String reasonLabel(WinReason r) => switch (r) {
    WinReason.points => t('reason_points'),
    WinReason.senshu => t('reason_senshu'),
    WinReason.ippon => t('reason_ippon'),
    WinReason.wazaAri => t('reason_waza_ari'),
    WinReason.hantei => t('reason_hantei'),
    WinReason.hansoku => t('reason_hansoku'),
    WinReason.pointGap => t('reason_gap'),
  };

  /// "Winner by IPPON" / "برنده با ایپون"
  String winnerBy(WinReason r) =>
      t('winner_by').replaceAll('{r}', reasonLabel(r));

  String penaltyName(PenaltyLevel p) => switch (p) {
    PenaltyLevel.none => '',
    PenaltyLevel.chui1 => '${t('chui')} 1',
    PenaltyLevel.chui2 => '${t('chui')} 2',
    PenaltyLevel.chui3 => '${t('chui')} 3',
    PenaltyLevel.hansokuChui => t('hansoku_chui'),
    PenaltyLevel.hansoku => t('hansoku'),
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'fa' || locale.languageCode == 'en';

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension TrX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => AppLocalizations.of(this).t(key);
}

const Map<String, Map<String, String>> _strings = {
  'en': {
    'app_title': 'Kumite Scoreboard',
    'quick_match': 'Quick Match',
    'quick_match_sub': 'Start now with default settings',
    'new_match': 'New Match',
    'settings': 'Settings',
    'history': 'Match History',
    'red': 'RED',
    'blue': 'BLUE',
    'red_name': 'Red fighter name',
    'blue_name': 'Blue fighter name',
    'duration': 'Match duration',
    'start_match': 'Start Match',
    'start': 'START',
    'pause': 'PAUSE',
    'resume': 'RESUME',
    'reset': 'Reset',
    'undo': 'Undo',
    'end_match': 'End',
    'status_ready': 'READY',
    'status_running': 'RUNNING',
    'status_paused': 'PAUSED',
    'status_final': 'FINAL',
    'press_start': 'Press START to begin',
    'yuko': 'YUKO',
    'waza_ari': 'WAZA-ARI',
    'ippon': 'IPPON',
    'senshu': 'SENSHU',
    'senshu_lost': 'Senshu cancelled by penalty',
    'chui': 'Chui',
    'hansoku_chui': 'Hansoku Chui',
    'hansoku': 'Hansoku',
    'penalty_add': 'Add penalty',
    'penalty_remove': 'Remove penalty',
    'now_leads': 'If time ends now:',
    'hantei_now': 'HANTEI',
    'wins': '{n} wins',
    'reason_points': 'POINTS',
    'reason_senshu': 'SENSHU',
    'reason_ippon': 'IPPON',
    'reason_waza_ari': 'WAZA-ARI',
    'reason_hantei': 'HANTEI',
    'reason_hansoku': 'HANSOKU (opponent)',
    'reason_gap': '8-POINT LEAD',
    'winner_by': 'Winner by {r}',
    'winner': 'WINNER',
    'final_score': 'Final score',
    'back_home': 'Back to Home',
    'hantei_title': 'HANTEI',
    'hantei_sub': 'Scores, IPPON and WAZA-ARI are all equal. Choose the judges\' decision.',
    'back': 'Back',
    'confirm_reset': 'Reset the timer to the full match time?',
    'confirm_leave': 'Leave the match? The current match will be lost.',
    'confirm_end': 'End the match now and decide the winner?',
    'confirm_hansoku': 'Give HANSOKU? The match ends and the opponent wins.',
    'confirm_delete': 'Delete this match from history?',
    'confirm_delete_all': 'Delete all match history?',
    'yes': 'Yes',
    'no': 'No',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'delete_all': 'Delete all',
    'history_empty': 'No matches yet',
    'vs': 'vs',
    'sound': 'Sound',
    'vibration': 'Vibration',
    'theme': 'Theme',
    'theme_dark': 'Dark',
    'theme_light': 'Light',
    'language': 'Language',
    'default_match': 'Default match settings',
    'point_gap_rule': 'End match at an 8-point lead',
    'seconds_short': 'sec',
  },
  'fa': {
    'app_title': 'اسکوربورد کومیته',
    'quick_match': 'مسابقه سریع',
    'quick_match_sub': 'شروع فوری با تنظیمات پیش‌فرض',
    'new_match': 'مسابقه جدید',
    'settings': 'تنظیمات',
    'history': 'تاریخچه مسابقات',
    'red': 'قرمز',
    'blue': 'آبی',
    'red_name': 'نام ورزشکار قرمز',
    'blue_name': 'نام ورزشکار آبی',
    'duration': 'مدت مسابقه',
    'start_match': 'شروع مسابقه',
    'start': 'شروع',
    'pause': 'توقف',
    'resume': 'ادامه',
    'reset': 'ریست',
    'undo': 'بازگرداندن',
    'end_match': 'پایان',
    'status_ready': 'آماده',
    'status_running': 'در جریان',
    'status_paused': 'متوقف',
    'status_final': 'پایان یافته',
    'press_start': 'برای شروع، دکمه شروع را بزنید',
    'yuko': 'یوکو',
    'waza_ari': 'وازاری',
    'ippon': 'ایپون',
    'senshu': 'سنشو',
    'senshu_lost': 'سنشو به دلیل خطا لغو شد',
    'chui': 'چویی',
    'hansoku_chui': 'هانسوکو چویی',
    'hansoku': 'هانسوکو',
    'penalty_add': 'افزودن خطا',
    'penalty_remove': 'کاستن خطا',
    'now_leads': 'اگر زمان همین الان تمام شود:',
    'hantei_now': 'هانتی',
    'wins': '{n} برنده است',
    'reason_points': 'امتیاز',
    'reason_senshu': 'سنشو',
    'reason_ippon': 'ایپون',
    'reason_waza_ari': 'وازاری',
    'reason_hantei': 'هانتی',
    'reason_hansoku': 'هانسوکو (حریف)',
    'reason_gap': 'اختلاف ۸ امتیاز',
    'winner_by': 'برنده با {r}',
    'winner': 'برنده',
    'final_score': 'امتیاز نهایی',
    'back_home': 'بازگشت به خانه',
    'hantei_title': 'هانتی',
    'hantei_sub':
        'امتیاز، ایپون و وازاری برابر است. نظر داوران را انتخاب کنید.',
    'back': 'بازگشت',
    'confirm_reset': 'زمان به مدت کامل مسابقه بازگردد؟',
    'confirm_leave': 'از مسابقه خارج می‌شوید؟ مسابقه فعلی از بین می‌رود.',
    'confirm_end': 'مسابقه همین حالا پایان یابد و برنده تعیین شود؟',
    'confirm_hansoku': 'هانسوکو ثبت شود؟ مسابقه تمام می‌شود و حریف برنده است.',
    'confirm_delete': 'این مسابقه از تاریخچه حذف شود؟',
    'confirm_delete_all': 'تمام تاریخچه حذف شود؟',
    'yes': 'بله',
    'no': 'خیر',
    'cancel': 'انصراف',
    'delete': 'حذف',
    'delete_all': 'حذف همه',
    'history_empty': 'هنوز مسابقه‌ای ثبت نشده',
    'vs': 'در برابر',
    'sound': 'صدا',
    'vibration': 'لرزش',
    'theme': 'تم',
    'theme_dark': 'تیره',
    'theme_light': 'روشن',
    'language': 'زبان',
    'default_match': 'تنظیمات پیش‌فرض مسابقه',
    'point_gap_rule': 'پایان مسابقه با اختلاف ۸ امتیاز',
    'seconds_short': 'ثانیه',
  },
};
