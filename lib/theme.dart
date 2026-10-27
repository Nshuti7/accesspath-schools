import 'package:flutter/material.dart';

/// Deep blue on white gives strong contrast (well above WCAG AA) and reads
/// clearly outdoors on low-cost phone screens.
const _primary = Color(0xFF0B4F8A);
const _error = Color(0xFFB3261E);

final ThemeData appTheme = _buildTheme();

ThemeData _buildTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _primary,
    primary: _primary,
    error: _error,
  );

  final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);

  // Text is one step larger than Material defaults so it stays readable for
  // staff with low vision and on small screens.
  final textTheme = base.textTheme.copyWith(
    headlineMedium: base.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 18, height: 1.5),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  );

  // 56px tall buttons are easier to hit for users with limited hand control.
  const minButtonSize = Size(64, 56);
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: Colors.white,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: minButtonSize,
        textStyle: textTheme.labelLarge,
        shape: buttonShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: textTheme.bodyLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      labelStyle: textTheme.bodyLarge,
      // Thick focus outline so keyboard users can see where they are.
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 2.5),
      ),
    ),
  );
}
