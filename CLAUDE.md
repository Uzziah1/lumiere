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
- Aucun serveur en V1. Sauvegardes locales uniquement (à venir).

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
- `art/` : dessin (papier, paysage, Colombe) — fonctions pures, testées sans écran
- `home/` : accueil (`HomeScreen` + scène Flame `HomeScene`)
- `screens/` : autres écrans (`ComingSoonScreen` pour les rubriques à venir)
- `widgets/` : composants d'interface réutilisables

## Tests

- `flutter test` depuis `app/` : widgets (navigation, mise en page petit téléphone portrait/paysage,
  réduire les animations), scènes Flame (`flame_test`), fonctions de dessin.
- Les écrans animés ne « se posent » jamais : avancer le temps avec `tester.pump(durée)`, pas `pumpAndSettle`.
- CI GitHub (`.github/workflows/ci.yml`) : analyse, tests, build web et APK à chaque push.

## Feuille de route

- **L0 — Socle** ✅ (à valider par Uzziah) : projet Flutter + Flame, thème papier découpé, polices, accueil animé
  (aube, collines, palmiers, village, poussière dorée, Colombe qu'on peut toucher), icônes, CI.
- **L1 — Noé (tranche verticale)** : récit animé, 3 mini-jeux (chronologie, cherche et trouve, memory), verset,
  récompenses, narration Piper.
- **L2** : carte du monde, îles, étoiles, profils, sauvegarde, trois âges.
- **L3** : lot 1 (8 histoires de l'Ancien Testament), tous les mini-jeux, album, l'arche-trésor.
- **L4** : espace parents, limites de temps, accessibilité, confidentialité, PWA et APK publics.
- **L5** : Nouveau Testament.
