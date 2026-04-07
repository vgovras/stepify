/// Scales an ingredient amount by the serving ratio.
///
/// Returns `null` if [baseAmount] is `null` (for "за смаком" ingredients).
/// Formula: `baseAmount * (currentServings / baseServings)`
double? scaleAmount({
  required double? baseAmount,
  required int baseServings,
  required int currentServings,
}) {
  if (baseAmount == null) return null;
  final scaled = baseAmount * currentServings / baseServings;
  // Round to 1 decimal to avoid floating-point noise (e.g. 1.0000000001)
  return (scaled * 10).round() / 10;
}
