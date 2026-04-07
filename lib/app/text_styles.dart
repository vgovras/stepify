import 'package:flutter/material.dart';

import '../core/core.dart';

/// Centralized text styles — fonts are bundled in assets/fonts/
/// and registered in pubspec.yaml.
abstract final class AppTextStyles {
  static const _body = 'Inter';
  static const _heading = 'Playfair Display';

  // ── Inter text theme (for ThemeData) ─────────────────
  static final interTextTheme = ThemeData.dark().textTheme.apply(
    fontFamily: _body,
  );

  // ── Playfair Display (headings / timers) ────────────
  static const screenTitle = TextStyle(
    fontFamily: _heading,
    fontSize: AppSizes.fontScreenTitle,
    fontWeight: FontWeight.w700,
  );

  static const sectionTitle = TextStyle(
    fontFamily: _heading,
    fontSize: AppSizes.fontSectionTitle,
    fontWeight: FontWeight.w700,
  );

  static const stepTitle = TextStyle(
    fontFamily: _heading,
    fontSize: AppSizes.fontStepTitle,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const timer = TextStyle(
    fontFamily: _heading,
    fontSize: AppSizes.fontTimer,
    fontWeight: FontWeight.w700,
  );

  static const timerLarge = TextStyle(
    fontFamily: _heading,
    fontSize: 38,
    fontWeight: FontWeight.w700,
  );

  static const floatBarTimer = TextStyle(
    fontFamily: _heading,
    fontSize: AppSizes.fontFloatBarTimer,
    fontWeight: FontWeight.w700,
  );

  static const cardTitle = TextStyle(
    fontFamily: _heading,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const servingValue = TextStyle(
    fontFamily: _heading,
    fontSize: AppSizes.fontServingValue,
    fontWeight: FontWeight.w700,
  );

  static const heading24 = TextStyle(
    fontFamily: _heading,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const heading21 = TextStyle(
    fontFamily: _heading,
    fontSize: 21,
    fontWeight: FontWeight.w700,
  );

  static const heading20 = TextStyle(
    fontFamily: _heading,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const heading32 = TextStyle(
    fontFamily: _heading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );
}
