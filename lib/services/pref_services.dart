import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_data.dart';

class PrefService {
  PrefService._(this._prefs);
  final SharedPreferences _prefs;

  // Semua key dikumpulkan di sini.
  static const _kOpenCount = 'open_count';
  static const _kProfile = 'profile_data';
  static const _kLastEdited = 'last_edited_at';
  static const _kHasSeenOnboarding = 'has_seen_onboarding';
  static const _kThemeMode = 'theme_mode';
  static const _kThemeColor = 'theme_color';

  // ---------- Profil ----------
  ProfileData get profile {
    final raw = _prefs.getString(_kProfile);
    if (raw == null) return ProfileData.defaults;
    try {
      return ProfileData.fromJson(raw);
    } catch (_) {
      // Data rusak? Jangan crash, kembali ke bawaan.
      return ProfileData.defaults;
    }
  }

  Future<void> saveProfile(ProfileData profile) =>
      _prefs.setString(_kProfile, profile.toJson());

  Future<void> clearProfile() => _prefs.remove(_kProfile);

  /// Dipanggil sekali saat aplikasi mulai.
  static Future<PrefService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefService._(prefs);
  }

  // ---------- Penghitung buka aplikasi ----------
  int get openCount => _prefs.getInt(_kOpenCount) ?? 0;

  Future<void> increaseOpenCount() => _prefs.setInt(_kOpenCount, openCount + 1);

  static const _kDarkMode = 'is_dark_mode';

  // ---------- Tema ----------
  bool get isDarkMode => _prefs.getBool(_kDarkMode) ?? false;

  Future<void> setDarkMode(bool value) => _prefs.setBool(_kDarkMode, value);

  // ---------- Debug (sementara, hapus nanti) ----------
  Set<String> get debugKeys => _prefs.getKeys();

  // ---------- Tantangan 1: Terakhir diedit (ISO 8601) ----------
  String? get lastEditedAt => _prefs.getString(_kLastEdited);

  Future<void> setLastEditedAt(DateTime time) =>
      _prefs.setString(_kLastEdited, time.toIso8601String());

  // ---------- Tantangan 2: Onboarding ----------
  bool get hasSeenOnboarding => _prefs.getBool(_kHasSeenOnboarding) ?? false;

  Future<void> setHasSeenOnboarding() =>
      _prefs.setBool(_kHasSeenOnboarding, true);

  // ---------- Tantangan 3: Mode tema (Sistem/Terang/Gelap) + warna ----------
  ThemeMode get themeMode {
    final i = _prefs.getInt(_kThemeMode);
    if (i == null || i < 0 || i > 2) return ThemeMode.system;
    return ThemeMode.values[i];
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setInt(_kThemeMode, mode.index);

  /// null = belum pernah dipilih (pakai warna bawaan indigo).
  Color? get themeColor {
    final v = _prefs.getInt(_kThemeColor);
    return v == null ? null : Color(v);
  }

  Future<void> setThemeColor(Color color) =>
      _prefs.setInt(_kThemeColor, color.toARGB32());

  Future<void> clearThemeColor() => _prefs.remove(_kThemeColor);
}
