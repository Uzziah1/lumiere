import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../story/age_group.dart';
import '../story/story_part.dart';
import 'save_data.dart';
import 'save_store.dart';

/// L'état du jeu sur l'appareil : profils, profil actif, progression.
/// Chaque changement est sauvegardé aussitôt.
class GameState extends ChangeNotifier {
  GameState(this._store, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final SaveStore _store;
  final DateTime Function() _clock;
  SaveData _data = SaveData();
  final _random = math.Random();

  /// Au plus quatre enfants par appareil.
  static const maxProfiles = 4;

  Future<void> load() async {
    try {
      final raw = await _store.read();
      _data = raw == null ? SaveData() : SaveData.fromJson(jsonDecode(raw));
    } catch (error) {
      debugPrint('Sauvegarde illisible, on repart de zéro : $error');
      _data = SaveData();
    }
    notifyListeners();
  }

  List<Profile> get profiles => List.unmodifiable(_data.profiles);

  Profile? get current {
    final id = _data.currentId;
    if (id == null) return null;
    for (final p in _data.profiles) {
      if (p.id == id) return p;
    }
    return null;
  }

  bool get canAddProfile => _data.profiles.length < maxProfiles;

  Profile addProfile({required String name, required AgeGroup age, required String avatar}) {
    if (!canAddProfile) throw StateError('Déjà $maxProfiles profils.');
    final profile = Profile(
      id: 'p${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_random.nextInt(1 << 20).toRadixString(36)}',
      name: cleanName(name),
      age: age,
      avatar: avatar,
    );
    _data.profiles.add(profile);
    _data.currentId = profile.id;
    _changed();
    return profile;
  }

  void updateProfile(Profile profile) {
    final i = _data.profiles.indexWhere((p) => p.id == profile.id);
    if (i < 0) return;
    _data.profiles[i] = profile.copyWith(name: cleanName(profile.name));
    _changed();
  }

  /// Supprime un profil et toute sa progression.
  void deleteProfile(String id) {
    _data.profiles.removeWhere((p) => p.id == id);
    _data.progress.remove(id);
    _data.playtime.remove(id);
    _data.extraTime.remove(id);
    if (_data.currentId == id) _data.currentId = null;
    _changed();
  }

  void select(String id) {
    if (!_data.profiles.any((p) => p.id == id) || _data.currentId == id) return;
    _data.currentId = id;
    _changed();
  }

  StoryProgress progress(String storyId, {String? profileId}) {
    final id = profileId ?? _data.currentId;
    return _data.progress[id]?[storyId] ?? StoryProgress.empty;
  }

  /// Étoiles gagnées par un profil, toutes histoires confondues.
  int totalStars(String profileId) =>
      (_data.progress[profileId] ?? const {}).values.fold(0, (sum, p) => sum + p.stars);

  void recordPart(String storyId, StoryPart part) {
    final id = _data.currentId;
    if (id == null) return;
    final before = progress(storyId);
    if (before.parts.contains(part)) return;
    (_data.progress[id] ??= {})[storyId] = before.withPart(part);
    _changed();
  }

  void earnSticker(String storyId) {
    final id = _data.currentId;
    if (id == null) return;
    final before = progress(storyId);
    if (before.sticker) return;
    (_data.progress[id] ??= {})[storyId] = before.withSticker();
    _changed();
  }

  // ── Réglages ────────────────────────────────────────────────────────────

  Settings get settings => _data.settings;

  void updateSettings(Settings settings) {
    _data.settings = settings;
    _changed();
  }

  // ── Temps de jeu ────────────────────────────────────────────────────────

  /// Ajoute du temps de jeu au profil actif (aujourd'hui) ; garde 14 jours.
  void addPlaytime(int seconds) {
    final id = _data.currentId;
    if (id == null || seconds <= 0) return;
    final days = _data.playtime[id] ??= {};
    final today = dayKey(_clock());
    days[today] = (days[today] ?? 0) + seconds;
    final oldest = dayKey(_clock().subtract(const Duration(days: 14)));
    days.removeWhere((key, _) => key.compareTo(oldest) < 0);
    _data.extraTime[id]?.removeWhere((key, _) => key != today);
    _changed();
  }

  Duration playtimeToday(String profileId) =>
      Duration(seconds: _data.playtime[profileId]?[dayKey(_clock())] ?? 0);

  /// Temps de jeu des 7 derniers jours (aujourd'hui compris).
  Duration playtimeWeek(String profileId) {
    final days = _data.playtime[profileId] ?? const {};
    var total = 0;
    for (var i = 0; i < 7; i++) {
      total += days[dayKey(_clock().subtract(Duration(days: i)))] ?? 0;
    }
    return Duration(seconds: total);
  }

  /// Un parent offre [minutes] de plus aujourd'hui au profil actif.
  void grantExtraTime(int minutes) {
    final id = _data.currentId;
    if (id == null) return;
    final days = _data.extraTime[id] ??= {};
    final today = dayKey(_clock());
    days[today] = (days[today] ?? 0) + minutes;
    _changed();
  }

  /// Temps qu'il reste aujourd'hui au profil actif, ou null s'il n'y a pas de limite.
  Duration? get remainingToday {
    final id = _data.currentId;
    final limit = _data.settings.dailyLimit;
    if (id == null || limit == 0) return null;
    final extra = _data.extraTime[id]?[dayKey(_clock())] ?? 0;
    final left = Duration(minutes: limit + extra) - playtimeToday(id);
    return left.isNegative ? Duration.zero : left;
  }

  bool get timeIsUp => remainingToday == Duration.zero;

  /// Prénom propre : espaces superflus retirés, longueur limitée.
  static String cleanName(String name) {
    final trimmed = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    return trimmed.characters.take(Profile.maxNameLength).toString();
  }

  void _changed() {
    notifyListeners();
    unawaited(
      _store.write(jsonEncode(_data.toJson())).catchError((Object error) {
        debugPrint('Sauvegarde impossible : $error');
      }),
    );
  }
}

/// Donne accès au [GameState] dans tout l'arbre, et reconstruit à chaque changement.
class GameScope extends InheritedNotifier<GameState> {
  const GameScope({super.key, required GameState state, required super.child}) : super(notifier: state);

  static GameState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GameScope>();
    assert(scope != null, 'GameScope manquant au-dessus de ce widget.');
    return scope!.notifier!;
  }

  /// Le [GameState] s'il y en a un (les tests d'un jeu seul n'en ont pas).
  static GameState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameScope>()?.notifier;

  /// Sans s'abonner aux changements (pour les actions).
  static GameState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<GameScope>()!.notifier!;
}
