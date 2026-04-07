import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Asset paths for all Twemoji SVG icons used in the app.
///
/// Twemoji by Twitter — CC-BY 4.0 license.
/// https://github.com/twitter/twemoji
abstract final class AppIcons {
  static const _base = 'assets/icons';

  // Food & cooking
  static const potOfFood = '$_base/pot_of_food.svg';
  static const cooking = '$_base/cooking.svg';

  // Navigation
  static const house = '$_base/house.svg';
  static const magnifyingGlass = '$_base/magnifying_glass.svg';
  static const shoppingCart = '$_base/shopping_cart.svg';
  static const bustInSilhouette = '$_base/bust_in_silhouette.svg';

  // Status & feedback
  static const partyPopper = '$_base/party_popper.svg';
  static const star = '$_base/star.svg';

  // Metadata
  static const stopwatch = '$_base/stopwatch.svg';
  static const fire = '$_base/fire.svg';
  static const highVoltage = '$_base/high_voltage.svg';

  /// Resolves a recipe's [iconAsset] name to a full asset path.
  static String forRecipe(String iconAsset) => '$_base/$iconAsset.svg';
}

/// Renders a Twemoji SVG asset at the given [size].
class SvgIcon extends StatelessWidget {
  const SvgIcon(this.assetPath, {super.key, this.size = 24});

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
    );
  }
}
