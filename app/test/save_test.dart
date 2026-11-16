import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere/save/game_state.dart';
import 'package:lumiere/save/save_data.dart';
import 'package:lumiere/save/save_store.dart';
import 'package:lumiere/story/age_group.dart';
import 'package:lumiere/story/story_part.dart';
import 'package:lumiere/theme/lumiere_theme.dart';

void main() {
  Future<GameState> fresh([MemorySaveStore? store]) async {
    final state = GameState(store ?? MemorySaveStore());
    await state.load();
    return state;
  }

  test('sans sauvegarde : aucun profil, aucun profil actif', () async {
    final state = await fresh();
    expect(state.profiles, isEmpty);
    expect(state.current, isNull);
    expect(state.canAddProfile, isTrue);
  });

  test('créer un profil le rend actif et le sauvegarde', () async {
    final store = MemorySaveStore();
    final state = await fresh(store);
    final awa = state.addProfile(name: '  Awa   Ouédraogo ', age: AgeGroup.agneaux, avatar: 'sheep');
    expect(awa.name, 'Awa Ouédraogo');
    expect(state.current?.id, awa.id);
    await Future<void>.delayed(Duration.zero);
    expect(store.writes, 1);

    final reloaded = await fresh(MemorySaveStore(store.data));
    expect(reloaded.profiles.single.name, 'Awa Ouédraogo');
    expect(reloaded.profiles.single.age, AgeGroup.agneaux);
    expect(reloaded.current?.id, awa.id);
  });

  test('le prénom est limité à 16 caractères', () {
    expect(GameState.cleanName('Abcdefghijklmnopqrstuvwxyz'), hasLength(16));
  });

  test('quatre profils au plus', () async {
    final state = await fresh();
    for (var i = 0; i < GameState.maxProfiles; i++) {
      state.addProfile(name: 'Enfant $i', age: AgeGroup.bergers, avatar: 'lion');
    }
    expect(state.canAddProfile, isFalse);
    expect(
      () => state.addProfile(name: 'Un de trop', age: AgeGroup.bergers, avatar: 'lion'),
      throwsStateError,
    );
  });

  test('les étoiles et l’autocollant sont gardés par profil et par histoire', () async {
    final store = MemorySaveStore();
    final state = await fresh(store);
    final awa = state.addProfile(name: 'Awa', age: AgeGroup.agneaux, avatar: 'sheep');
    state.recordPart('noe', StoryPart.recit);
    state.recordPart('noe', StoryPart.memory);
    state.recordPart('noe', StoryPart.memory);
    state.earnSticker('noe');
    final ibrahim = state.addProfile(name: 'Ibrahim', age: AgeGroup.explorateurs, avatar: 'owl');

    expect(state.current?.id, ibrahim.id);
    expect(state.progress('noe').stars, 0);
    expect(state.progress('noe', profileId: awa.id).stars, 2);
    expect(state.progress('noe', profileId: awa.id).sticker, isTrue);
    expect(state.totalStars(awa.id), 2);

    final reloaded = await fresh(MemorySaveStore(store.data));
    expect(reloaded.progress('noe', profileId: awa.id).parts, {StoryPart.recit, StoryPart.memory});
  });

  test('modifier puis supprimer un profil (et sa progression)', () async {
    final state = await fresh();
    final awa = state.addProfile(name: 'Awa', age: AgeGroup.agneaux, avatar: 'sheep');
    state.recordPart('noe', StoryPart.recit);
    state.updateProfile(awa.copyWith(name: 'Awa B.', age: AgeGroup.bergers, avatar: 'owl'));
    expect(state.current!.name, 'Awa B.');
    expect(state.current!.age, AgeGroup.bergers);

    state.deleteProfile(awa.id);
    expect(state.profiles, isEmpty);
    expect(state.current, isNull);
    expect(state.totalStars(awa.id), 0);
  });

  test('une sauvegarde abîmée ne plante pas le jeu', () async {
    for (final broken in [
      'pas du json',
      '[]',
      '{"profiles": 3}',
      jsonEncode({
        'profiles': [
          {'id': 1},
        ],
      }),
    ]) {
      final state = await fresh(MemorySaveStore(broken));
      expect(state.profiles, isEmpty, reason: broken);
    }
  });

  test('un âge ou un avatar inconnu est remplacé par une valeur sûre', () {
    final p = Profile.fromJson({'id': 'x', 'name': 'Zoé', 'age': 'bebes', 'avatar': 'dragon'});
    expect(p.age, AgeGroup.bergers);
    expect(p.avatar, avatarChoices.first);
  });

  test('typographie française : insécable avant ! ? et dans les guillemets', () {
    expect(frenchSpacing('Bravo ! Quel âge as-tu ?'), 'Bravo\u00A0! Quel âge as-tu\u00A0?');
    expect(frenchSpacing('« Sors de l’arche »'), '«\u00A0Sors de l’arche\u00A0»');
  });
}
