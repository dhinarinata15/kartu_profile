import 'package:flutter/material.dart';

import 'pages/onboarding_page.dart';
import 'pages/profile_page.dart';
import 'services/pref_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // wajib sebelum await di main
  final prefs = await PrefService.init();
  debugPrint('Isi prefs: ${prefs.debugKeys}'); // debug sementara
  await prefs.increaseOpenCount();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.prefs});
  final PrefService prefs;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Nilai awal dibaca dari penyimpanan, bukan hard-coded.
  late final ValueNotifier<ThemeMode> _themeMode;
  late final ValueNotifier<Color?> _themeColor;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    // Nilai awal dibaca dari penyimpanan di initState, bukan initializer.
    _themeMode = ValueNotifier(widget.prefs.themeMode);
    _themeColor = ValueNotifier(widget.prefs.themeColor);
    _showOnboarding = !widget.prefs.hasSeenOnboarding;
  }

  void _changeThemeMode(ThemeMode mode) {
    _themeMode.value = mode; // 1. ubah tampilan sekarang
    widget.prefs.setThemeMode(mode); // 2. simpan untuk nanti
  }

  void _changeThemeColor(Color? color) {
    _themeColor.value = color;
    if (color == null) {
      widget.prefs.clearThemeColor();
    } else {
      widget.prefs.setThemeColor(color);
    }
  }

  void _finishOnboarding() {
    widget.prefs.setHasSeenOnboarding();
    setState(() => _showOnboarding = false);
  }

  void _replayOnboarding() {
    setState(() => _showOnboarding = true);
  }

  @override
  void dispose() {
    _themeMode.dispose();
    _themeColor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Color?>(
          valueListenable: _themeColor,
          builder: (context, themeColor, _) {
            return MaterialApp(
              title: 'Kartu Profil Digital',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: themeColor ?? Colors.indigo,
                ),
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: themeColor ?? Colors.indigo,
                  brightness: Brightness.dark,
                ),
              ),
              themeMode: themeMode,
              home: _showOnboarding
                  ? OnboardingPage(onDone: _finishOnboarding)
                  : ProfilePage(
                      prefs: widget.prefs,
                      themeMode: themeMode,
                      onThemeModeChanged: _changeThemeMode,
                      themeColor: themeColor,
                      onThemeColorChanged: _changeThemeColor,
                      onReplayOnboarding: _replayOnboarding,
                    ),
            );
          },
        );
      },
    );
  }
}
