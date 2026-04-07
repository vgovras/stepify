import 'package:flutter/material.dart';

/// Renders emoji using the platform's default font, bypassing
/// the app's custom Inter/Playfair Display theme fonts.
///
/// iOS doesn't fall back to Apple Color Emoji when a custom
/// [fontFamily] is set via the theme. Wrapping emoji in a fresh
/// [DefaultTextStyle] with no fontFamily lets the engine use
/// the platform's built-in emoji typeface.
class EmojiText extends StatelessWidget {
  const EmojiText(this.emoji, {super.key, this.fontSize = 24});

  final String emoji;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(),
      child: Text(emoji, style: TextStyle(fontSize: fontSize)),
    );
  }
}
