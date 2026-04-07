import 'package:flutter/material.dart';

import '../core/core.dart';

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.bg,
  fontFamily: 'DM Sans',
  colorScheme: const ColorScheme.dark(
    surface: AppColors.bg,
    primary: AppColors.ac,
    secondary: AppColors.ac2,
    error: AppColors.rd,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    fontFamily: 'DM Sans',
    bodyColor: AppColors.tx,
    displayColor: AppColors.tx,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.bg,
    foregroundColor: AppColors.tx,
    elevation: 0,
  ),
  cardTheme: const CardThemeData(
    color: AppColors.s1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusCard)),
      side: BorderSide(color: AppColors.br),
    ),
  ),
);
