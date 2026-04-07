import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/core.dart';

/// Centralized text styles — all [GoogleFonts] calls happen here once
/// as `static final` fields, never inside `build()`.
abstract final class AppTextStyles {
  // ── DM Sans text theme (for ThemeData) ──────────────
  static final dmSansTextTheme = GoogleFonts.dmSansTextTheme(
    ThemeData.dark().textTheme,
  );

  // ── Playfair Display (headings / timers) ────────────
  static final screenTitle = GoogleFonts.playfairDisplay(
    fontSize: AppSizes.fontScreenTitle,
    fontWeight: FontWeight.w700,
  );

  static final sectionTitle = GoogleFonts.playfairDisplay(
    fontSize: AppSizes.fontSectionTitle,
    fontWeight: FontWeight.w700,
  );

  static final stepTitle = GoogleFonts.playfairDisplay(
    fontSize: AppSizes.fontStepTitle,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static final timer = GoogleFonts.playfairDisplay(
    fontSize: AppSizes.fontTimer,
    fontWeight: FontWeight.w700,
  );

  static final timerLarge = GoogleFonts.playfairDisplay(
    fontSize: 38,
    fontWeight: FontWeight.w700,
  );

  static final floatBarTimer = GoogleFonts.playfairDisplay(
    fontSize: AppSizes.fontFloatBarTimer,
    fontWeight: FontWeight.w700,
  );

  static final cardTitle = GoogleFonts.playfairDisplay(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static final servingValue = GoogleFonts.playfairDisplay(
    fontSize: AppSizes.fontServingValue,
    fontWeight: FontWeight.w700,
  );

  static final heading24 = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static final heading21 = GoogleFonts.playfairDisplay(
    fontSize: 21,
    fontWeight: FontWeight.w700,
  );

  static final heading20 = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static final heading32 = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );
}
