import 'package:flutter/services.dart';

import 'common_lines.dart';
import 'story.dart';

/// Charge les histoires et les phrases communes depuis les assets.
class StoryRepository {
  StoryRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final _stories = <String, Story>{};
  CommonLines? _common;

  Future<Story> story(String id) async {
    final cached = _stories[id];
    if (cached != null) return cached;
    final story = Story.parse(await _bundle.loadString('assets/stories/$id/story.json'));
    return _stories[id] = story;
  }

  Future<CommonLines> common() async =>
      _common ??= CommonLines.parse(await _bundle.loadString('assets/lines/common.json'));
}
