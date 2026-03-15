import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _boxName = 'settings';
  static const _key = 'themeMode';

  ThemeCubit() : super(ThemeMode.system);

  /// Call once at app start to restore the persisted preference.
  Future<void> init() async {
    final box = await Hive.openBox(_boxName);
    final stored = box.get(_key, defaultValue: 'system') as String;
    emit(_fromString(stored));
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    final box = await Hive.openBox(_boxName);
    await box.put(_key, _toString(mode));
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        setTheme(ThemeMode.dark);
      case ThemeMode.dark:
        setTheme(ThemeMode.system);
      case ThemeMode.system:
        setTheme(ThemeMode.light);
    }
  }

  static ThemeMode _fromString(String value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static String _toString(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}
