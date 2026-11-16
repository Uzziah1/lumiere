import '../story/age_group.dart';
import '../story/story_part.dart';

/// Les avatars proposés aux enfants (des animaux de Lumière).
const avatarChoices = ['sheep', 'lion', 'owl', 'rabbit', 'giraffe', 'elephant', 'tortoise', 'dove'];

/// Un enfant qui joue sur cet appareil. Tout reste sur l'appareil : rien n'est envoyé.
class Profile {
  const Profile({required this.id, required this.name, required this.age, required this.avatar});

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    name: json['name'] as String,
    age: AgeGroup.byName(json['age'] as String?) ?? AgeGroup.bergers,
    avatar: avatarChoices.contains(json['avatar']) ? json['avatar'] as String : avatarChoices.first,
  );

  final String id;

  /// Prénom ou surnom.
  final String name;
  final AgeGroup age;

  /// Nom d'un animal de [avatarChoices].
  final String avatar;

  static const maxNameLength = 16;

  Profile copyWith({String? name, AgeGroup? age, String? avatar}) =>
      Profile(id: id, name: name ?? this.name, age: age ?? this.age, avatar: avatar ?? this.avatar);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'age': age.name, 'avatar': avatar};
}

/// Ce qu'un enfant a réussi dans une histoire.
class StoryProgress {
  const StoryProgress({this.parts = const {}, this.sticker = false});

  factory StoryProgress.fromJson(Map<String, dynamic> json) => StoryProgress(
    parts: {
      for (final name in (json['parts'] as List? ?? const []).cast<String>())
        if (StoryPart.byName(name) != null) StoryPart.byName(name)!,
    },
    sticker: json['sticker'] == true,
  );

  static const empty = StoryProgress();

  final Set<StoryPart> parts;

  /// Vrai quand l'enfant a terminé l'histoire et gagné l'autocollant.
  final bool sticker;

  int get stars => parts.length;

  StoryProgress withPart(StoryPart part) => StoryProgress(parts: {...parts, part}, sticker: sticker);

  StoryProgress withSticker() => StoryProgress(parts: parts, sticker: true);

  Map<String, dynamic> toJson() => {
    'parts': [
      for (final p in StoryPart.values)
        if (parts.contains(p)) p.name,
    ],
    'sticker': sticker,
  };
}

/// Quand afficher les sous-titres du récit.
enum SubtitleMode {
  /// Selon l'âge (pas pour les Agneaux), et toujours si la narration est coupée.
  auto,
  always,
  never;

  static SubtitleMode byName(Object? name) =>
      values.firstWhere((m) => m.name == name, orElse: () => SubtitleMode.auto);
}

/// Réglages de l'appareil, choisis par les parents.
class Settings {
  const Settings({
    this.narration = true,
    this.effects = true,
    this.music = true,
    this.subtitles = SubtitleMode.auto,
    this.reduceMotion = false,
    this.largeText = false,
    this.dailyLimit = 0,
  });

  factory Settings.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return const Settings();
    final limit = json['dailyLimit'];
    return Settings(
      narration: json['narration'] != false,
      effects: json['effects'] != false,
      music: json['music'] != false,
      subtitles: SubtitleMode.byName(json['subtitles']),
      reduceMotion: json['reduceMotion'] == true,
      largeText: json['largeText'] == true,
      dailyLimit: limit is int && dailyLimitChoices.contains(limit) ? limit : 0,
    );
  }

  /// Limites de temps proposées, en minutes (0 = pas de limite).
  static const dailyLimitChoices = [0, 15, 30, 45, 60, 90];

  /// La voix qui raconte.
  final bool narration;

  /// Les bruitages.
  final bool effects;

  /// La musique de fond.
  final bool music;
  final SubtitleMode subtitles;

  /// Réduire les animations (en plus du réglage du téléphone).
  final bool reduceMotion;

  /// Textes un peu plus grands.
  final bool largeText;

  /// Temps de jeu quotidien par enfant, en minutes (0 = pas de limite).
  final int dailyLimit;

  /// Faut-il des sous-titres pour [age] ? Toujours quand la voix est coupée.
  bool subtitlesFor(AgeGroup age) {
    if (!narration) return true;
    return switch (subtitles) {
      SubtitleMode.always => true,
      SubtitleMode.never => false,
      SubtitleMode.auto => age.showsSubtitles,
    };
  }

  Settings copyWith({
    bool? narration,
    bool? effects,
    bool? music,
    SubtitleMode? subtitles,
    bool? reduceMotion,
    bool? largeText,
    int? dailyLimit,
  }) => Settings(
    narration: narration ?? this.narration,
    effects: effects ?? this.effects,
    music: music ?? this.music,
    subtitles: subtitles ?? this.subtitles,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    largeText: largeText ?? this.largeText,
    dailyLimit: dailyLimit ?? this.dailyLimit,
  );

  Map<String, dynamic> toJson() => {
    'narration': narration,
    'effects': effects,
    'music': music,
    'subtitles': subtitles.name,
    'reduceMotion': reduceMotion,
    'largeText': largeText,
    'dailyLimit': dailyLimit,
  };
}

/// Clé d'un jour local, ex. « 2026-11-16 ».
String dayKey(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

Map<String, Map<String, int>> _perDay(Object? json) {
  final result = <String, Map<String, int>>{};
  if (json is! Map<String, dynamic>) return result;
  for (final MapEntry(key: profileId, value: days) in json.entries) {
    if (days is! Map<String, dynamic>) continue;
    result[profileId] = {
      for (final MapEntry(:key, :value) in days.entries)
        if (value is int) key: value,
    };
  }
  return result;
}

/// Toute la sauvegarde de l'appareil.
class SaveData {
  SaveData({
    List<Profile>? profiles,
    this.currentId,
    Map<String, Map<String, StoryProgress>>? progress,
    this.settings = const Settings(),
    Map<String, Map<String, int>>? playtime,
    Map<String, Map<String, int>>? extraTime,
  }) : profiles = profiles ?? [],
       progress = progress ?? {},
       playtime = playtime ?? {},
       extraTime = extraTime ?? {};

  /// Lit une sauvegarde ; une sauvegarde abîmée ne bloque jamais le jeu
  /// (on repart de zéro plutôt que de planter).
  factory SaveData.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return SaveData();
    try {
      final profiles = [
        for (final p in (json['profiles'] as List? ?? const []).cast<Map<String, dynamic>>())
          Profile.fromJson(p),
      ];
      final progress = <String, Map<String, StoryProgress>>{};
      final raw = json['progress'] as Map<String, dynamic>? ?? const {};
      for (final MapEntry(key: profileId, value: stories) in raw.entries) {
        progress[profileId] = {
          for (final MapEntry(key: storyId, value: p) in (stories as Map<String, dynamic>).entries)
            storyId: StoryProgress.fromJson(p as Map<String, dynamic>),
        };
      }
      final current = json['current'] as String?;
      return SaveData(
        profiles: profiles,
        currentId: profiles.any((p) => p.id == current) ? current : null,
        progress: progress,
        settings: Settings.fromJson(json['settings']),
        playtime: _perDay(json['playtime']),
        extraTime: _perDay(json['extraTime']),
      );
    } catch (_) {
      return SaveData();
    }
  }

  static const version = 2;

  final List<Profile> profiles;
  String? currentId;

  /// Progression par profil puis par histoire.
  final Map<String, Map<String, StoryProgress>> progress;

  Settings settings;

  /// Secondes de jeu par profil et par jour (14 derniers jours).
  final Map<String, Map<String, int>> playtime;

  /// Minutes de jeu offertes par un parent, par profil et par jour.
  final Map<String, Map<String, int>> extraTime;

  Map<String, dynamic> toJson() => {
    'version': version,
    'profiles': [for (final p in profiles) p.toJson()],
    'current': currentId,
    'progress': {
      for (final MapEntry(key: profileId, value: stories) in progress.entries)
        profileId: {for (final MapEntry(:key, :value) in stories.entries) key: value.toJson()},
    },
    'settings': settings.toJson(),
    'playtime': playtime,
    'extraTime': extraTime,
  };
}
