import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeController extends _$ThemeController {
  @override
  FutureOr<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPref = prefs.containsKey('splitwise-dark-mode');

    if (hasPref) {
      // If user has already chosen a mode, use it
      final isDark = prefs.getBool('splitwise-dark-mode') ?? false;
      return isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      // Otherwise, get system brightness
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final systemTheme = brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;

      // Save it as the initial preference
      await prefs.setBool('splitwise-dark-mode', systemTheme == ThemeMode.dark);
      return systemTheme;
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = state.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await prefs.setBool('splitwise-dark-mode', newMode == ThemeMode.dark);
    state = AsyncData(newMode);
  }
}
