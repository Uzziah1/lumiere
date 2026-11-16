import 'dart:convert';

import 'age_group.dart';
import 'narrated_text.dart';

/// Les phrases de Colombe communes à toutes les histoires (encouragements,
/// indices), dans `assets/lines/common.json`.
class CommonLines {
  CommonLines(this.lines);

  factory CommonLines.parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return CommonLines({for (final e in json.entries) e.key: NarratedText.fromJson(e.value)});
  }

  final Map<String, NarratedText> lines;

  String audioPath(String key, AgeGroup age) => commonAudioPath(key, lines[key]!.variantFor(age));
}

String commonAudioPath(String key, String variant) => 'audio/lines/$key.$variant.mp3';
