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

/// Toute la sauvegarde de l'appareil.
class SaveData {
  SaveData({List<Profile>? profiles, this.currentId, Map<String, Map<String, StoryProgress>>? progress})
    : profiles = profiles ?? [],
      progress = progress ?? {};

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
      );
    } catch (_) {
      return SaveData();
    }
  }

  static const version = 1;

  final List<Profile> profiles;
  String? currentId;

  /// Progression par profil puis par histoire.
  final Map<String, Map<String, StoryProgress>> progress;

  Map<String, dynamic> toJson() => {
    'version': version,
    'profiles': [for (final p in profiles) p.toJson()],
    'current': currentId,
    'progress': {
      for (final MapEntry(key: profileId, value: stories) in progress.entries)
        profileId: {for (final MapEntry(:key, :value) in stories.entries) key: value.toJson()},
    },
  };
}
