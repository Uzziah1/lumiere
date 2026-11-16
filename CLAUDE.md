# Lumière — instructions pour Claude

Lumière est un jeu vidéo **gratuit, sans publicité et sans collecte de données** qui fait découvrir la Bible
aux enfants de **4 à 12 ans**, sur téléphone (Android d'abord) et sur le web. Public : familles et églises
**évangéliques / protestantes** d'Afrique francophone, puis toute la francophonie.

Le document de conception complet est dans **`docs/GDD.md`** : le lire avant toute nouvelle étape et le tenir
à jour (section « Décisions prises ») quand une décision change.

Propriétaire du projet : Uzziah (développeur full-stack, Ouagadougou). **Aucun budget** : uniquement des outils
et ressources libres, ou produits par nous.

## Façon de travailler (à respecter)

- **Une étape à la fois.** Uzziah valide chaque étape avant qu'on passe à la suivante.
  Finir l'étape en cours (code + tests verts), la résumer avec des captures d'écran, puis attendre sa validation.
- **Push direct sur `main`**, pas de PR. Commits clairs, en français, un commit par étape logique.
- **Tests obligatoires** : `flutter analyze` sans aucun avertissement et `flutter test` verts avant tout push.
- Quand Uzziah demande une modification de fichier, il préfère recevoir le **fichier complet réécrit**.
- Langue : échanges, commits et textes affichés en **français** ; code (classes, variables) en **anglais** ;
  commentaires du code en français.
- Uzziah développe sous **Windows** (Git Bash / MINGW64) : commandes compatibles, pas de chemins Unix en dur.

## Principes du jeu (non négociables, détails dans le GDD)

1. **Fidèle à la Bible** : récits simplifiés, jamais inventés sur le fond ; référence toujours affichée ;
   versets en **Louis Segond 1910** (domaine public), jamais d'autre traduction sous droits. Pas d'apocryphes.
2. **Dieu n'est jamais dessiné comme un personnage** : lumière, voix, rayons. Jésus est représenté avec dignité.
3. **Aucun échec qui punit** : une erreur = un indice de Colombe.
4. **Sûr pour l'enfant** : ni pub, ni compte, ni chat, ni lien externe hors espace parents, ni donnée envoyée,
   ni bibliothèque de statistiques. Politique « Familles » de Google Play.
5. **Hors ligne, léger, fluide** : tout est dans l'appli (polices comprises, pas de CDN) ; 60 images/s visées
   sur un Android d'entrée de gamme (2 Go de RAM).
6. **Accessible** : boutons ≥ 48 px (64 px pour les actions principales), libellés `Semantics`, et
   « réduire les animations » respecté (`MediaQuery.disableAnimations` : la scène s'arrête).

## Stack

- Application Flutter dans **`app/`** (Flutter stable 3.50+, Dart 3.14+), Android, web, iOS plus tard.
  - Depuis Flutter 3.50, Material est le paquet **`material_ui`** : importer `package:material_ui/material_ui.dart`
    (pas `package:flutter/material.dart`).
  - **Flame** pour les scènes de jeu (`FlameGame`, composants), widgets Flutter pour les menus.
  - **go_router** pour la navigation (fondu entre écrans, `lib/router.dart`).
- Jeu **à l'horizontale** (verrouillé sur téléphone dans `main.dart`, Android `sensorLandscape`) ;
  les écrans restent lisibles en vertical sur le web.
- Aucun serveur en V1. Sauvegarde locale uniquement (`shared_preferences`, clé `lumiere.save`, une chaîne JSON).

## Direction artistique — « papier découpé lumineux »

- Tout est **dessiné en code** (chemins vectoriels), pas d'images d'illustration : formes arrondies empilées,
  chacune avec une ombre douce (`drawPaper` dans `lib/art/paper.dart`), grain de papier (`PaperGrain`),
  dégradés chauds, halos et poussière dorée.
- Couleurs : `lib/theme/palette.dart` (palette « Aube » de l'accueil + couleurs d'interface). Chaque histoire
  aura sa palette dominante.
- Polices intégrées (OFL, `app/assets/fonts`) : **Fredoka** (titres, variable : graisse via `FontVariation`,
  voir `LumiereText.title`) et **Andika** (texte, faite pour les jeunes lecteurs).
- **Colombe** (`lib/art/colombe.dart`) : la colombe guide, dessinée dans une boîte 100 × 80, ailes qui battent
  (`flap`), yeux qui clignent (`blink`), rameau d'olivier. Les icônes de l'appli sont générées à partir d'elle :
  `flutter test tool/render_icons_test.dart` (depuis `app/`).
- Composants d'interface : `PaperButton` (papier épais qui s'enfonce, `lib/widgets/paper_button.dart`),
  `LumiereTitle` (lettres de papier qui flottent).

## Arborescence de `app/lib`

- `main.dart`, `app.dart`, `router.dart`
- `theme/` : palette et styles de texte
- `art/` : dessin (papier, paysage, Colombe, personnages `people.dart` — tête nue, couronne, casque —,
  animaux `animals.dart`, objets `objects.dart` (`paintThing` : objets et animaux par identifiant), arche
  `ark.dart`, météo `weather.dart`, outils de décor `scenery.dart`) — fonctions pures, testées sans écran. Planche de tous les dessins :
  `flutter test tool/art_sheet_test.dart` → `build/art_sheet.png`
- `home/` : accueil (`HomeScreen` + scène Flame `HomeScene`)
- `story/` : moteur d'histoire, commun à toutes les histoires — modèle (`Story`, `NarratedText`, `AgeGroup`),
  chargement (`StoryRepository`), `StorySession` (histoire + âge + voix), théâtre Flame (`StoryGame`,
  `StoryStage`, `HintRing`, `Sparkles`), écrans (`StoryScreen` : intro/âge → `RecitView` → `StoryHub` →
  jeux → `StoryReward`)
- `games/` : mini-jeux génériques (`ChronologyGame`, `SeekGame`, `MemoryGame`, `VerseGame`) dans un `GameFrame`
- `stories/` : le code propre à chaque histoire (`registry.dart` : `StoryPack` = décors, vignettes,
  scène de cache-cache, autocollant, objets des mini-jeux) ; un dossier par histoire : `creation`, `eden`,
  `noe`, `abraham`, `joseph`, `moise`, `david`, `jonas` (Ancien Testament), `naissance`, `temple`, `bapteme`,
  `tempete`, `pains`, `zachee`, `samaritain`, `prodigue`, `paques`, `pentecote`, `cana` (Nouveau Testament),
  `jericho`, `gedeon`, `ruth`, `samuel`, `elie`, `daniel`, `esther` (les héros de la foi) ;
  `ot/heroes.dart` : personnages et décors des héros de la foi (`Heroes.joshua`, `Heroes.priest`,
  `Heroes.people`, `paintPeople`, `paintCovenantArk`, `paintWalledCity`) ;
  `nt/nt.dart` : personnages et décors communs au Nouveau Testament (`NT.jesus`, `NT.mary`, `NT.disciples`,
  `paintAngel`, `paintCrowd`, `paintGalilee`, `paintJerusalem`, `paintHouse`, `paintRoad`, `paintBaby`)
- `audio/` : `Narrator`, `SoundEffects` et `MusicPlayer` (audioplayers ; versions muettes pour les tests),
  `AudioScope`, `MusicDirector` (musique choisie selon l'écran, `trackFor`), `DuckingNarrator` (la musique
  baisse quand la conteuse parle)
- `save/` : `SaveData` (profils, profil actif, progression par profil et par histoire), `SaveStore`
  (`PrefsSaveStore`, `MemorySaveStore` pour les tests), `GameState` (ChangeNotifier, sauvegarde à chaque
  changement) et `GameScope` (`GameScope.of` pour l'affichage, `GameScope.read` pour les actions)
- `profiles/` : « Qui joue ? » (`/profils`), création et modification (`/profils/nouveau`, `/profils/:id`)
- `world/` : la carte du monde (`/carte`) — îles `lot1` (les origines), `lot3` (les héros de la foi) et `lot2`
  (Nouveau Testament), dans cet ordre sur la carte : `allIslands`, `islandsOfLot` (`world.dart` : règles
  d'ouverture `World`, ami de chaque île `treasure`), monuments dessinés (`landmarks.dart`), `WorldMapScreen`
  (un panneau au début de chaque partie), l'album (`/album`, `AlbumScreen`, 26 autocollants) et les trois
  trésors de `TreasureScreen(lot:)` : l'arche (`/tresor`, lot 1), le coffre (`/coffre`, lot 3) et le jardin
  (`/jardin`, lot 2), avec des boutons pour passer de l'un à l'autre
- `parents/` : espace parents (`/parents`, `ParentsScreen` : enfants, réglages, à propos), politique de
  confidentialité et crédits (`privacy.dart`), temps de jeu et écran « À demain » (`play_time.dart`)
- `screens/` : autres écrans (`ComingSoonScreen` pour les rubriques à venir)
- `widgets/` : composants d'interface réutilisables (`PaperButton`, `RoundPaperButton`, `ColombeBubble`,
  `AgeCard`, `ProfileAvatar`, `PaperBackdrop`, `showParentalGate`…)

## Profils, carte et progression

- Parcours : Accueil → « Jouer » → `/profils` (sans profil : création directe) → `/carte` → île → `/histoire/:id`.
- Profil : prénom ou surnom (16 caractères), âge (`AgeGroup`), avatar (animal de `avatarChoices`) ; 4 au plus.
  Tout reste sur l'appareil. Une sauvegarde abîmée ne plante jamais : on repart de zéro.
- Modifier ou supprimer un profil passe par la **barrière parentale** (`showParentalGate` : multiplication
  écrite en lettres, réutilisée pour l'espace parents en L4).
- Une île est **ouverte** si son histoire existe (`storyPacks`) et si l'histoire existante précédente a au moins
  3 étoiles (`World.starsToUnlock`) ; sinon **fermée** ; une histoire pas encore construite est **bientôt**.
- Avec un profil, l'histoire prend l'âge du profil (pas d'écran de choix), reprend les étoiles déjà gagnées,
  sauvegarde chaque étoile aussitôt (`recordPart`) et l'autocollant à la fin (`earnSticker`).
- Textes affichés : `frenchSpacing` (espace insécable avant ! ? ; : et dans les guillemets).

## Espace parents, réglages, temps de jeu

- `/parents` s'ouvre par la barrière parentale. Réglages (`Settings` dans la sauvegarde, version 2) : voix
  (`GatedNarrator` : sans voix, attente du temps de lecture), bruitages (`GatedSoundEffects`), sous-titres
  (`Settings.subtitlesFor` : selon l'âge, toujours, jamais ; toujours sans voix), réduire les animations et
  textes plus grands (appliqués à `MediaQuery` dans `app.dart`), limite quotidienne (0, 15… 90 min).
- `PlayTimeKeeper` (dans `app.dart`) compte le temps du profil actif sur `/carte`, `/album`, les trésors
  (`/tresor`, `/coffre`, `/jardin`) et `/histoire/*` (pas à l'accueil ni chez les parents), prévient 2 min avant, puis affiche `TimeUpScreen` par-dessus
  tout ; la barrière y est intégrée (pas de boîte de dialogue : l'écran recouvre la navigation). Un parent ajoute
  15 ou 30 min (`grantExtraTime`). Dans les tests : `LumiereApp(trackPlaytime: false, …)` et `onTick()` à la main.
- Politique de confidentialité : `lib/parents/privacy.dart` = `docs/confidentialite.md` = `web/confidentialite.html`
  (vérifié par `privacy_test.dart`). Aucune autorisation Android (vérifié aussi).

## Publication (voir `docs/PUBLICATION.md`)

- Web : `sw.js` (service worker maison : préchargement ~5 Mo listé par `tools/web/precache.py`, narration gardée
  à l'écoute, moteur d'affichage signalé par la page), publié sur GitHub Pages par `.github/workflows/pages.yml`.
- Android : `.github/workflows/release.yml` sur une étiquette `v*` → Release GitHub avec APK et AAB ; signature de
  publication si les secrets `ANDROID_KEYSTORE_*` existent (`android/key.properties`, jamais commité).
- Version : `pubspec.yaml` (`version`) et `lib/version.dart` (affichée chez les parents).

## Histoires : données, décors, narration

- Une histoire = un dossier **`app/assets/stories/<id>/`** : `story.json` (scènes, textes par âge, jeux, verset,
  autocollant) + `audio/` (narration générée). Une phrase narrée est une chaîne (tous âges) ou un objet
  `{"all", "agneaux", "bergers", "explorateurs"}` ; clés audio : `<clé>.<variante>.mp3` (voir `Story.fromJson`).
- Le code de l'histoire va dans `lib/stories/<id>/` et s'inscrit dans `storyPacks` (`lib/stories/registry.dart`).
  **Nouvelles histoires : `StoryPack.scripted`** avec une `StageScript` par scène (`lib/story/scripted_stage.dart`) :
  une fonction de dessin qui reçoit un `StageView` (temps, avancement, cibles touchées) et des zones à toucher
  relatives. Interactions : `tapAll` (toucher chaque cible), `tapRepeat` (toucher N fois), `swipe` (glisser),
  `tapThenWait` (toucher puis regarder). Les cartes de la chronologie portent l'identifiant de la scène ; leurs
  vignettes et l'autocollant sont la scène terminée. Noé, plus ancien, garde ses décors Flame sur mesure.
  Vérifier une histoire d'un coup d'œil : `flutter test tool/story_sheet_test.dart --dart-define=STORY=<id>`
  → `build/story_<id>.png` (scènes au début et terminées, zones à toucher, cache-cache, autocollant, memory).
- Ajouter une histoire : dossier d'assets (+ deux lignes `assets` dans `pubspec.yaml`), dossier de code,
  entrée dans `storyPacks`, île dans `lot1`, `lot2` ou `lot3` (`world.dart`), puis la narration. Le test
  `scripted_stories_test.dart` vérifie automatiquement chaque scène.
  Chaque décor (`StoryStage`) : dessine sa scène, dit où toucher (`hintTarget`, toujours au-dessus des
  sous-titres, < 85 % de la hauteur) et appelle `complete()` quand l'action est faite. `layout()` peut être
  rappelé : ne remet rien à zéro si la taille ne change pas.
- **Narration** : `python tools/narration/generate.py --voice <fr_FR-siwis-medium.onnx>` (Piper + ffmpeg),
  régénère seulement les phrases modifiées (`tools/narration/manifest.json`). À relancer après toute
  modification d'un texte ; le test `story_data_test.dart` échoue si un fichier audio manque.
- **Bruitages** : synthétisés par `python tools/sfx/generate.py` (numpy + ffmpeg), dans `app/assets/audio/sfx/`.
- **Musique** : quatre morceaux en boucle (`home`, `map`, `story`, `games`) synthétisés par
  `python tools/music/generate.py` (kalimba, balafon, shaker, nappes ; numpy + ffmpeg), dans
  `app/assets/audio/music/`. Réglage « musique » chez les parents ; silence quand le temps de jeu est écoulé.
- Le Nouveau Testament : Jésus toujours digne et doux ; la croix est une silhouette au loin, au crépuscule,
  sans souffrance montrée, et l'histoire se termine sur la résurrection. L'Esprit saint : vent, flammes,
  colombe — jamais un personnage.
- **Versets** : texte exact de la Louis Segond 1910, à vérifier dans une Bible papier avant publication.
- Phrases communes de Colombe (encouragements, indices) : `app/assets/lines/common.json`.

## Tests

- `flutter test` depuis `app/` : widgets (navigation, mise en page petit téléphone portrait/paysage,
  réduire les animations), scènes Flame (`flame_test`), fonctions de dessin.
- Les écrans animés ne « se posent » jamais : avancer le temps avec `tester.pump(durée)`, pas `pumpAndSettle`.
- Profils dans les tests : `LumiereApp(gameState: GameState(MemorySaveStore()))` (sinon : en mémoire).
- Sons muets dans les tests : `LumiereApp(narrator: SilentNarrator(instant: true), sfx: SilentSoundEffects())`,
  ou `inSession(...)` (`test/helpers.dart`) pour un jeu seul. Les tests qui chargent les assets font
  `setUp(rootBundle.clear)`.
- CI GitHub (`.github/workflows/ci.yml`) : analyse, tests, build web et APK à chaque push.

## Feuille de route

- **L0 — Socle** ✅ : projet Flutter + Flame, thème papier découpé, polices, accueil animé
  (aube, collines, palmiers, village, poussière dorée, Colombe qu'on peut toucher), icônes, CI.
- **L1 — Noé (tranche verticale)** ✅ : choix de l'âge, récit animé de 8 scènes interactives
  (Genèse 6–9) raconté par Piper (voix siwis) avec sous-titres et indices, 3 mini-jeux (chronologie,
  cache-cache, memory), verset Genèse 9.13 selon l'âge, 5 étoiles et autocollant, bruitages synthétisés.
- **L2 — Carte, profils, sauvegarde** ✅ : jusqu'à 4 profils (prénom, âge, avatar),
  « Qui joue ? », barrière parentale pour modifier/supprimer, carte du monde à 8 îles (Noé jouable, les autres
  « bientôt »), déblocage à 3 étoiles, étoiles et autocollants sauvegardés sur l'appareil.
- **L3 — Lot 1** ✅ : les 8 histoires de l'Ancien Testament jouables (La Création, Adam et
  Ève, Noé, Abraham, Joseph, Moïse, David, Jonas), six scènes chacune (huit pour Noé), cache-cache et memory
  propres à chaque histoire, versets, album d'autocollants, arche-trésor (un ami par histoire terminée).
- **L4 — Parents et publication** ✅ : espace parents (progression, réglages, à propos),
  limite de temps quotidienne, voix/bruitages/sous-titres/animations/grand texte réglables, politique de
  confidentialité (jeu, docs, web), jeu web hors ligne sur GitHub Pages, APK/AAB publiés sur étiquette.
- **L5 — Nouveau Testament et musique** ✅ : musique synthétisée sur chaque écran,
  10 histoires du Nouveau Testament (naissance, Temple, baptême, tempête, pains, Zachée, bon Samaritain,
  fils prodigue, Pâques, Pentecôte), deuxième partie de la carte, album de 18 autocollants, jardin-trésor.
- **L6 — Les héros de la foi** ✅ (à valider par Uzziah) : 7 histoires de l'Ancien Testament (Jéricho, Gédéon,
  Ruth, Samuel, Élie, Daniel, Esther) entre les deux Testaments sur la carte, coffre au trésor, et les noces de
  Cana dans le Nouveau Testament (11 histoires, jardin à 11 amis) ; 26 histoires en tout.
- **L7** : à définir avec Uzziah (nouveaux types de jeux, Play Store, voix réelles, lot 4…).
