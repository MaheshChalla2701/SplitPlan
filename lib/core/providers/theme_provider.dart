import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

// Provide SharedPreferences synchronously
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main',
  );
});

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeModeKey = 'themeMode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final userAsync = ref.watch(authStateProvider);

    // Initial local read for fastest boot
    bool isDark = prefs.getBool(_themeModeKey) ?? false;

    // Override with cloud preference if user is authenticated
    final user = userAsync.valueOrNull;
    if (user != null) {
      isDark = user.isDarkMode;
      // Sync it back to local storage instantly so next app boot remembers it
      prefs.setBool(_themeModeKey, isDark);
    }

    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;

    // Save locally
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_themeModeKey, isDark);

    // Sync to cloud if authenticated
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({'isDarkMode': isDark})
          .catchError((_) {});
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
