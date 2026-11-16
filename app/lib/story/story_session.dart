import 'package:flutter/widgets.dart';

import '../audio/audio.dart';
import '../stories/registry.dart';
import 'age_group.dart';
import 'common_lines.dart';
import 'story.dart';

/// Tout ce qu'il faut pendant une histoire : les données, l'âge choisi, le
/// code de l'histoire (décors, vignettes) et la voix.
class StorySession extends InheritedWidget {
  const StorySession({
    super.key,
    required this.story,
    required this.common,
    required this.age,
    required this.pack,
    required this.narrator,
    required this.sfx,
    required super.child,
  });

  final Story story;
  final CommonLines common;
  final AgeGroup age;
  final StoryPack pack;
  final Narrator narrator;
  final SoundEffects sfx;

  static StorySession of(BuildContext context) {
    final session = context.dependOnInheritedWidgetOfExactType<StorySession>();
    assert(session != null, 'StorySession manquante au-dessus de ce widget.');
    return session!;
  }

  /// Le texte d'une phrase (de l'histoire ou commune) pour l'âge choisi.
  String text(String key) => (story.lines[key] ?? common.lines[key])!.textFor(age);

  /// Fait dire une phrase par la narratrice.
  Future<void> say(String key) {
    final path = story.lines.containsKey(key) ? story.audioPath(key, age) : common.audioPath(key, age);
    return narrator.play(path, text: text(key));
  }

  @override
  bool updateShouldNotify(StorySession oldWidget) =>
      story != oldWidget.story || age != oldWidget.age || narrator != oldWidget.narrator;
}
