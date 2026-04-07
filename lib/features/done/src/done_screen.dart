import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/core.dart';
import '../../../shared_ui/shared_ui.dart';
import 'done_cubit.dart';
import 'done_state.dart';

/// Cooking completion screen with confetti and rating.
class DoneScreen extends StatefulWidget {
  const DoneScreen({super.key});

  @override
  State<DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends State<DoneScreen> with TickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final AnimationController _emojiController;
  late final Animation<double> _emojiScale;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: AppDurations.confettiLifetime,
    )..forward();

    _emojiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _emojiScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_emojiController);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _showRatingSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.s1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<DoneCubit>(),
        child: const _RatingSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoneCubit, DoneState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Stack(
            children: [
              // Confetti layer
              _ConfettiLayer(controller: _confettiController),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenHorizontal,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      // Emoji with pop-in
                      ScaleTransition(
                        scale: _emojiScale,
                        child: const Text('🎉', style: TextStyle(fontSize: 68)),
                      ),
                      const SizedBox(height: 20),
                      // Heading
                      Text(
                        'Смачного!',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tx,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Subtitle
                      Text(
                        '${state.recipeName} готовий.\n'
                        'Ви чудово впорались!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.t2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Stats row
                      StatGrid(
                        cells: [
                          StatCell(
                            value: '${state.timeMinutes} хв',
                            label: 'Час',
                          ),
                          StatCell(value: '${state.servings}', label: 'Порції'),
                          const StatCell(value: '+1', label: 'Страва'),
                        ],
                      ),
                      const Spacer(flex: 2),
                      // Action buttons
                      PrimaryButton(
                        label: '⭐ Оцінити рецепт',
                        onPressed: state.hasRated ? null : _showRatingSheet,
                        isDisabled: state.hasRated,
                      ),
                      const SizedBox(height: 12),
                      GhostButton(
                        label: '📤 Поділитись',
                        onPressed: () =>
                            showAppToast(context, 'Поділитись — в розробці'),
                      ),
                      const SizedBox(height: 12),
                      GhostButton(
                        label: '🏠 На головну',
                        onPressed: () => context.go('/'),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Confetti ────────────────────────────────────────────

/// Custom confetti effect using colored falling containers.
///
/// Particles are generated once in [initState] and reused across
/// animation frames to avoid allocating objects on every build.
class _ConfettiLayer extends StatefulWidget {
  const _ConfettiLayer({required this.controller});

  final AnimationController controller;

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer> {
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

// ── Rating Sheet ────────────────────────────────────────

class _RatingSheet extends StatefulWidget {
  const _RatingSheet();

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _stars = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.screenHorizontal,
        20,
        AppSizes.screenHorizontal,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.br,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Оцініть рецепт',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.tx,
            ),
          ),
          const SizedBox(height: 16),
          // Star row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final filled = index < _stars;
              return GestureDetector(
                onTap: () => setState(() => _stars = index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 36,
                    color: filled ? AppColors.ac : AppColors.t3,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Comment field
          TextField(
            controller: _commentController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: AppColors.tx),
            decoration: InputDecoration(
              hintText: 'Залишити коментар...',
              hintStyle: const TextStyle(color: AppColors.t3),
              filled: true,
              fillColor: AppColors.s2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.br),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.br),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.ac),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Submit button
          PrimaryButton(
            label: 'Надіслати',
            isDisabled: _stars == 0,
            onPressed: _stars == 0
                ? null
                : () {
                    context.read<DoneCubit>().submitRating(
                      _stars,
                      _commentController.text,
                    );
                    Navigator.of(context).pop();
                    showAppToast(context, 'Дякуємо за оцінку!');
                  },
          ),
        ],
      ),
    );
  }
}
