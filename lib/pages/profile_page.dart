import 'package:flutter/material.dart';

import '../models/profile_data.dart';
import '../services/pref_services.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.prefs,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.themeColor,
    required this.onThemeColorChanged,
    required this.onReplayOnboarding,
  });

  final PrefService prefs;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Color? themeColor;
  final ValueChanged<Color?> onThemeColorChanged;
  final VoidCallback onReplayOnboarding;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileData _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.prefs.profile; // baca data tersimpan
  }

  Future<void> _edit() async {
    final result = await Navigator.push<ProfileData>(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(initial: _profile)),
    );
    if (result == null) return; // pengguna menekan back

    await widget.prefs.saveProfile(result);
    // Tantangan 1: catat waktu terakhir diedit (ISO 8601)
    await widget.prefs.setLastEditedAt(DateTime.now());
    if (!mounted) return;
    setState(() => _profile = result);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profil tersimpan')));
  }

  Future<void> _reset() async {
    await widget.prefs.clearProfile();
    if (!mounted) return;
    setState(() => _profile = widget.prefs.profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil dikembalikan ke bawaan')),
    );
  }

  Future<void> _pickThemeMode() async {
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Mode Tema'),
        children: [
          RadioGroup<ThemeMode>(
            groupValue: widget.themeMode,
            onChanged: (value) => Navigator.pop(context, value),
            child: Column(
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    title: Text(switch (mode) {
                      ThemeMode.system => 'Ikuti Sistem',
                      ThemeMode.light => 'Terang',
                      ThemeMode.dark => 'Gelap',
                    }),
                    value: mode,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected != null) widget.onThemeModeChanged(selected);
  }

  Future<void> _pickThemeColor() async {
    const choices = <String, Color>{
      'Indigo (bawaan)': Colors.indigo,
      'Biru': Colors.blue,
      'Hijau': Colors.green,
      'Merah': Colors.red,
      'Oranye': Colors.orange,
      'Ungu': Colors.purple,
      'Teal': Colors.teal,
    };
    Color? selected;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warna Tema'),
        content: SingleChildScrollView(
          child: RadioGroup<String>(
            groupValue: _currentColorKey(choices),
            onChanged: (value) => selected = choices[value!],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in choices.entries)
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        CircleAvatar(radius: 12, backgroundColor: entry.value),
                        const SizedBox(width: 12),
                        Text(entry.key),
                      ],
                    ),
                    value: entry.key,
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              widget.onThemeColorChanged(selected);
              Navigator.pop(context);
            },
            child: const Text('Pilih'),
          ),
        ],
      ),
    );
  }

  /// Mencocokkan warna aktif dengan daftar pilihan, null = pakai indigo.
  String? _currentColorKey(Map<String, Color> choices) {
    final current = widget.themeColor ?? Colors.indigo;
    for (final entry in choices.entries) {
      if (entry.value.toARGB32() == current.toARGB32()) return entry.key;
    }
    return null;
  }

  String _formatLastEdited(String? iso) {
    if (iso == null) return 'Belum pernah diedit';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return 'Belum pernah diedit';
    final local = dt.toLocal();
    final d = '${local.day}/${local.month}/${local.year}';
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return 'Terakhir diedit: $d $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initial = _profile.name.isNotEmpty
        ? _profile.name[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartu Profil Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit profil',
            onPressed: _edit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colors.primaryContainer,
                    child: Text(initial, style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _profile.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(_profile.title),
                  const SizedBox(height: 12),
                  Text(_profile.bio, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  // Tantangan 1: waktu terakhir diedit
                  Text(
                    _formatLastEdited(widget.prefs.lastEditedAt),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Tantangan 3: mode tema 3 pilihan + warna tema
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Mode Tema'),
            subtitle: Text(switch (widget.themeMode) {
              ThemeMode.system => 'Ikuti Sistem',
              ThemeMode.light => 'Terang',
              ThemeMode.dark => 'Gelap',
            }),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickThemeMode,
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Warna Tema'),
            trailing: CircleAvatar(
              radius: 12,
              backgroundColor: widget.themeColor ?? Colors.indigo,
            ),
            onTap: _pickThemeColor,
          ),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.restore),
            label: const Text('Reset Profil'),
          ),
          OutlinedButton.icon(
            onPressed: widget.onReplayOnboarding,
            icon: const Icon(Icons.replay),
            label: const Text('Lihat Onboarding Lagi'),
          ),
          // Lab 11 akan menambahkan menu "Proyek Saya" di sini.
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Kartu ini sudah dibuka ${widget.prefs.openCount} kali',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
