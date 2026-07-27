import 'package:flutter/material.dart';

abstract final class AppTokens {
  static const colorBgApp = Color(0xFFF7F9FB);
  static const colorBgSurface = Color(0xFFFFFFFF);
  static const colorBgSubtle = Color(0xFFEEF2F5);
  static const colorTextPrimary = Color(0xFF15232E);
  static const colorTextSecondary = Color(0xFF4E5D6B);
  static const colorTextMuted = Color(0xFF697785);
  static const colorBorderDefault = Color(0xFFDEE5EA);
  static const colorBorderStrong = Color(0xFFC7D0D8);
  static const colorActionPrimary = Color(0xFF2E5673);
  static const colorActionPrimarySubtle = Color(0xFFEFF6FA);
  static const colorStatusSuccess = Color(0xFF23845B);
  static const colorStatusWarning = Color(0xFFA86A10);
  static const colorStatusDanger = Color(0xFF96372F);

  static const space1 = 4.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space5 = 20.0;
  static const space6 = 24.0;
  static const space8 = 32.0;

  static const radiusSm = 4.0;
  static const radiusMd = 8.0;
  static const radiusLg = 12.0;
  static const radiusXl = 16.0;

  static const motionFast = Duration(milliseconds: 150);
  static const motionNormal = Duration(milliseconds: 250);
}
