import 'package:flutter/material.dart';

import 'router.dart';
import 'shader_warmup.dart';
import 'theme.dart';

/// Platform emoji fonts so every Text widget can render emoji glyphs.
/// iOS/macOS need explicit fallback because GoogleFonts sets a custom
/// fontFamily that doesn't include the system emoji typeface.
const _emojiFallback = [
  'Apple Color Emoji',
  'Noto Color Emoji',
  'Segoe UI Emoji',
];

class StepifyApp extends StatelessWidget {
  const StepifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderWarmup(
      child: MaterialApp.router(
        title: 'Stepify',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        routerConfig: appRouter,
        builder: (context, child) {
          return DefaultTextStyle.merge(
            style: const TextStyle(fontFamilyFallback: _emojiFallback),
            child: child!,
          );
        },
      ),
    );
  }
}
