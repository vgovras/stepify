import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../shared_ui/shared_ui.dart';
import '../cook_state.dart';

/// Dynamic bottom button that changes label and style based on [ButtonState].
class BottomActionBtn extends StatelessWidget {
  const BottomActionBtn({
    super.key,
    required this.buttonState,
    required this.onPressed,
    required this.isLastStep,
  });

  final ButtonState buttonState;
  final VoidCallback onPressed;
  final bool isLastStep;

  @override
  Widget build(BuildContext context) {
    final (label, style, disabled) = _config;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      child: PrimaryButton(
        label: label,
        onPressed: onPressed,
        isDisabled: disabled,
        customStyle: style,
      ),
    );
  }

  (String, BoxDecoration?, bool) get _config => switch (buttonState) {
    ButtonState.next || ButtonState.bgTimerNext => ('Далі →', null, false),
    ButtonState.blockingStart => ('Далі →', null, false),
    ButtonState.blockingRunning => (
      '⏸ Пауза',
      BoxDecoration(
        color: const Color(0x1F_D46060),
        border: Border.all(color: AppColors.rd, width: 1.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
      ),
      false,
    ),
    ButtonState.blockingPaused => ('▶ Продовжити', null, false),
    ButtonState.blockingDone => ('Далі →', null, false),
    ButtonState.lastStep => ('🎉 Готово!', null, false),
    ButtonState.waiting => (
      'Очікування...',
      BoxDecoration(
        color: AppColors.s2,
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
      ),
      true,
    ),
  };
}
