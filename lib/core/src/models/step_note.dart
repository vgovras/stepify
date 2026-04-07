import 'package:flutter/foundation.dart';

import 'enums.dart';

@immutable
class StepNote {
  const StepNote({required this.type, required this.text});

  final NoteType type;
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepNote &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          text == other.text;

  @override
  int get hashCode => Object.hash(type, text);
}
