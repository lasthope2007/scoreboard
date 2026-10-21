import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/match_record.dart';

class HistoryController extends ChangeNotifier {
  HistoryController(this._prefs);

  static const _key = 'matchHistory';
  final SharedPreferences _prefs;
  List<MatchRecord> _items = [];

  List<MatchRecord> get items => List.unmodifiable(_items);

  void load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _items = list
          .map((e) => MatchRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _items = []; // corrupted data must never block the app
    }
  }

  void _persist() => _prefs.setString(
    _key,
    jsonEncode(_items.map((e) => e.toJson()).toList()),
  );

  void add(MatchRecord record) {
    _items.insert(0, record);
    if (_items.length > kMaxHistoryItems) {
      _items = _items.sublist(0, kMaxHistoryItems);
    }
    _persist();
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  void clear() {
    _items = [];
    _persist();
    notifyListeners();
  }
}
