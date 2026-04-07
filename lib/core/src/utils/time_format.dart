/// Formats [totalSeconds] as "MM:SS" with leading zeros.
///
/// Negative values are clamped to "00:00".
String formatTimer(int totalSeconds) {
  final clamped = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = (clamped ~/ 60).toString().padLeft(2, '0');
  final seconds = (clamped % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
