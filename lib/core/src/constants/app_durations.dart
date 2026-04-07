/// Animation and transition duration tokens.
abstract final class AppDurations {
  static const stepTransition = Duration(milliseconds: 200);
  static const progressBar = Duration(milliseconds: 400);
  static const toast = Duration(milliseconds: 2700);
  static const screenTransition = Duration(milliseconds: 240);
  static const confettiLifetime = Duration(seconds: 4);

  /// Timer urgency threshold — last 15% of total time.
  static const double urgencyFraction = 0.15;

  /// Float bar urgency threshold in seconds.
  static const int floatBarUrgencySeconds = 60;

  /// Max simultaneous float bars.
  static const int maxFloatBars = 2;

  /// Confetti particle count.
  static const int confettiParticles = 55;
}
