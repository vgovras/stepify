import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/text_styles.dart';
import '../../../core/core.dart';
import '../../../shared_ui/shared_ui.dart';
import 'done_cubit.dart';
import 'done_state.dart';
import 'widgets/confetti_layer.dart';
import 'widgets/rating_sheet.dart';

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
        child: const RatingSheet(),
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
              ConfettiLayer(controller: _confettiController),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenHorizontal,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      ScaleTransition(
                        scale: _emojiScale,
                        child: const SvgIcon(
                          AppIcons.partyPopper,
                          size: 68,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Смачного!',
                        style: AppTextStyles.screenTitle.copyWith(
                          color: AppColors.tx,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      PrimaryButton(
                        label: 'Оцінити рецепт',
                        onPressed: state.hasRated ? null : _showRatingSheet,
                        isDisabled: state.hasRated,
                      ),
                      const SizedBox(height: 12),
                      GhostButton(
                        label: 'Поділитись',
                        onPressed: () =>
                            showAppToast(context, 'Поділитись — в розробці'),
                      ),
                      const SizedBox(height: 12),
                      GhostButton(
                        label: 'На головну',
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
