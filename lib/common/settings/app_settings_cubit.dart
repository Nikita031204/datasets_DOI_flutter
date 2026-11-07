import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
class AppSettings {
  const AppSettings({required this.themeMode, required this.locale});

  final ThemeMode themeMode;
  final Locale locale;
}

class AppSettingsCubit extends Cubit<AppSettings> {
  AppSettingsCubit()
    : super(
        const AppSettings(themeMode: ThemeMode.system, locale: Locale('ru')),
      );

  void toggleTheme(Brightness currentBrightness) {
    emit(
      AppSettings(
        themeMode: currentBrightness == Brightness.dark
            ? ThemeMode.light
            : ThemeMode.dark,
        locale: state.locale,
      ),
    );
  }

  void setLocale(Locale locale) {
    emit(AppSettings(themeMode: state.themeMode, locale: locale));
  }
}
