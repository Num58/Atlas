import 'package:flutter/material.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppTokens.colorActionPrimary,
      onPrimary: AppTokens.colorBgSurface,
      surface: AppTokens.colorBgSurface,
      onSurface: AppTokens.colorTextPrimary,
      error: AppTokens.colorStatusDanger,
      onError: AppTokens.colorBgSurface,
      outline: AppTokens.colorBorderDefault,
      outlineVariant: AppTokens.colorBorderStrong,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppTokens.colorBgApp,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['Noto Sans SC'],
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontSize: 24,
          height: 32 / 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.24,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontSize: 18,
          height: 24 / 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 20 / 14,
          color: AppTokens.colorTextSecondary,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.colorBgSurface,
        contentPadding: const EdgeInsets.all(AppTokens.space4),
        border: _inputBorder(AppTokens.colorBorderDefault),
        enabledBorder: _inputBorder(AppTokens.colorBorderDefault),
        focusedBorder: _inputBorder(AppTokens.colorActionPrimary, width: 2),
        errorBorder: _inputBorder(AppTokens.colorStatusDanger),
        focusedErrorBorder: _inputBorder(AppTokens.colorStatusDanger, width: 2),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppTokens.colorBgSurface,
        indicatorColor: AppTokens.colorActionPrimarySubtle,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
