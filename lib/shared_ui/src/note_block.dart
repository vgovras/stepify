import 'package:flutter/material.dart';

import '../../core/core.dart';

/// Styled note block for tips, warnings, and pro hints.
class NoteBlock extends StatelessWidget {
  const NoteBlock({super.key, required this.note});

  final StepNote note;

  @override
  Widget build(BuildContext context) {
    final (bg, border) = switch (note.type) {
      NoteType.warn => (const Color(0x14D46060), const Color(0x33D46060)),
      NoteType.tip => (const Color(0x12E8B44C), const Color(0x26E8B44C)),
      NoteType.pro => (const Color(0x126AAF6A), const Color(0x266AAF6A)),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        note.text,
        style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.t2),
      ),
    );
  }
}
