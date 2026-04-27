import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LanguageCubit extends Cubit<Locale> {
  static const _boxName = 'settings';
  static const _key = 'languageCode';

  LanguageCubit() : super(const Locale('en'));

  Future<void> init() async {
    final box = await Hive.openBox(_boxName);
    final stored = box.get(_key, defaultValue: 'en') as String;
    emit(_fromCode(stored));
  }

  Future<void> setLanguage(Locale locale) async {
    emit(locale);
    final box = await Hive.openBox(_boxName);
    await box.put(_key, locale.languageCode);
  }

  static Locale _fromCode(String code) {
    switch (code) {
      case 'om':
        return const Locale('om');
      case 'am':
        return const Locale('am');
      default:
        return const Locale('en');
    }
  }
}
