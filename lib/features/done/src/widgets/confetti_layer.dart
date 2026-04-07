import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Custom confetti effect using colored falling containers.
///
/// Particles are generated once in [didChangeDependencies] and reused
/// across animation frames to avoid allocating objects on every build.
class ConfettiLayer extends StatefulWidget {
  const ConfettiLayer({super.key, required this.controller});

  final AnimationController controller;

  @override
  State<ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<ConfettiLayer> {
  static const _colors = [
    AppColors.ac,
    AppColors.ac2,
    AppColors.gr,
    AppColors.tx,
    AppColors.rd,
  ];

  List<_Particle> _particles = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      final screenWidth = MediaQuery.of(context).size.width;
      final random = Random(42);
      _particles = List.generate(
        AppDurations.confettiParticles,
        (i) => _Particle(
          x: random.nextDouble() * screenWidth,
          delay: random.nextDouble(),
          speed: 0.4 + random.nextDouble() * 0.6,
          size: 4.0 + random.nextDouble() * 6.0,
          color: _colors[i % _colors.length],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return IgnorePointer(
          child: CustomPaint(
            size: size,
            painter: _ConfettiPainter(
              particles: _particles,
              progress: widget.controller.value,
              screenHeight: size.height,
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.color,
  });

  final double x;
  final double delay;
  final double speed;
  final double size;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.screenHeight,
  });

  final List<_Particle> particles;
  final double progress;
  final double screenHeight;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final adjustedProgress = ((progress - p.delay * 0.3) * p.speed).clamp(
        0.0,
        1.0,
      );
      if (adjustedProgress <= 0) continue;

      final y = adjustedProgress * screenHeight * 1.2 - 20;
      final opacity = (1.0 - adjustedProgress).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(p.x, y),
            width: p.size,
            height: p.size * 1.4,
          ),
          Radius.circular(p.size * 0.2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
