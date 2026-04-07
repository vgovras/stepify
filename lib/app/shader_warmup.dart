import 'package:flutter/material.dart';

import '../core/core.dart';
import 'text_styles.dart';

/// Warms up CanvasKit shaders and shows a branded splash screen
/// while the app initializes, then fades into the real content.
class ShaderWarmup extends StatefulWidget {
  const ShaderWarmup({super.key, required this.child});

  final Widget child;

  @override
  State<ShaderWarmup> createState() => _ShaderWarmupState();
}

class _ShaderWarmupState extends State<ShaderWarmup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  bool _showChild = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // Frame 1: render warm-up primitives + splash.
    // Frame 2+: shaders compiled, start fade to real app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Give an extra frame for shaders to fully compile.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _showChild = true);
          _fadeController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // Warm-up primitives — off-screen, rendered in first frame only.
          if (!_showChild)
            const Positioned(
              left: -9999,
              top: -9999,
              child: SizedBox(
                width: 100,
                height: 2000,
                child: _WarmupPrimitives(),
              ),
            ),
          // Splash screen — visible during warm-up, fades out.
          if (!_showChild || _fadeController.isAnimating) const _SplashScreen(),
          // Real app — fades in after warm-up.
          if (_showChild)
            FadeTransition(opacity: _fadeController, child: widget.child),
        ],
      ),
    );
  }
}

/// Branded splash screen shown while shaders compile.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🍲', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Stepify',
            style: AppTextStyles.heading32.copyWith(color: AppColors.ac),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.ac,
            ),
          ),
        ],
      ),
    );
  }
}

/// All shader-triggering primitives in the app, collected in one widget.
/// Rendered off-screen in the first frame so CanvasKit pre-compiles
/// their shaders before the user sees any content.
class _WarmupPrimitives extends StatelessWidget {
  const _WarmupPrimitives();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // LinearGradient — gold to orange (PrimaryButton, TimerDisplay)
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.ac, AppColors.ac2]),
          ),
        ),
        // LinearGradient — top to bottom with transparency (RecipeCard fade)
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.s1.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
        // LinearGradient — 3-stop (DetailScreen hero)
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.s2, AppColors.bg, AppColors.bg],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
        ),
        // LinearGradient — subtle gold (TimerDisplay, WaitingView)
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x1C_E8B44C), Color(0x12_D4793A)],
            ),
          ),
        ),
        // BoxShadow — gold glow (PrimaryButton)
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.ac,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40E8B44C),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
        ),
        // ClipRRect — rounded (progress bars)
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: const SizedBox(width: 50, height: 3),
        ),
        // Clip.antiAlias — rounded container (RecipeCard, StatGrid)
        Container(
          width: 50,
          height: 50,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.s1,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.br),
          ),
        ),
        // BorderRadius with border (many widgets)
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.s2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.br),
          ),
        ),
        // Circular shape (FloatBar dot, profile avatar)
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.ac,
            shape: BoxShape.circle,
          ),
        ),
        // Text rendering warm-up — both font families
        Text('W', style: AppTextStyles.floatBarTimer),
        const Text('W', style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
