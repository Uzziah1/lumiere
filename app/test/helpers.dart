import 'dart:io';

import 'package:lumiere/audio/audio.dart';
import 'package:lumiere/stories/registry.dart';
import 'package:lumiere/story/age_group.dart';
import 'package:lumiere/story/common_lines.dart';
import 'package:lumiere/story/story.dart';
import 'package:lumiere/story/story_session.dart';
import 'package:material_ui/material_ui.dart';

Story loadStory(String id) => Story.parse(File('assets/stories/$id/story.json').readAsStringSync());

CommonLines loadCommon() => CommonLines.parse(File('assets/lines/common.json').readAsStringSync());

/// Une histoire prête à jouer dans un test, sons muets et narration instantanée.
Widget inSession(
  Widget child, {
  AgeGroup age = AgeGroup.bergers,
  String storyId = 'noe',
  SilentNarrator? narrator,
  SilentSoundEffects? sfx,
}) {
  return MaterialApp(
    home: StorySession(
      story: loadStory(storyId),
      common: loadCommon(),
      age: age,
      pack: storyPacks[storyId]!,
      narrator: narrator ?? SilentNarrator(instant: true),
      sfx: sfx ?? SilentSoundEffects(),
      child: Scaffold(body: child),
    ),
  );
}
