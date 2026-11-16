# Lumière

**La Bible en jeux pour les enfants de 4 à 12 ans.** Gratuit, sans publicité, sans collecte de données,
jouable hors ligne, sur Android et sur le web.

L'enfant voyage sur la carte du monde de la Bible avec Colombe, une petite colombe guide : chaque histoire
se vit (récit animé et raconté), se joue (mini-jeux) et se retient (verset, autocollant).

- Conception du jeu : [`docs/GDD.md`](docs/GDD.md)
- Application Flutter : [`app/`](app/)

## Lancer le jeu

Prérequis : [Flutter](https://docs.flutter.dev/get-started/install) stable 3.50 ou plus récent.

```bash
cd app
flutter pub get
flutter run -d chrome
```

Sur un téléphone Android branché en USB (mode développeur activé) :

```bash
flutter run
```

## Vérifier avant de pousser

```bash
flutter analyze
flutter test
```

## Régénérer les icônes

Les icônes (Android, iOS, web) sont dessinées à partir de Colombe :

```bash
flutter test tool/render_icons_test.dart
```

## Narration et bruitages

La narration est générée hors ligne avec [Piper](https://github.com/rhasspy/piper) (voix libre
`fr_FR-siwis-medium`) ; les bruitages sont synthétisés. Après avoir modifié un texte d'histoire :

```bash
pip install piper-tts numpy
```

```bash
python tools/narration/generate.py --voice chemin/vers/fr_FR-siwis-medium.onnx
```

(Voix à télécharger depuis [piper-voices](https://huggingface.co/rhasspy/piper-voices/tree/main/fr/fr_FR/siwis/medium) ;
ffmpeg doit être installé.)

## Licences et crédits

- Polices : [Fredoka](https://fonts.google.com/specimen/Fredoka) et [Andika](https://software.sil.org/andika/)
  (SIL Open Font License, textes dans `app/assets/fonts/`).
- Textes bibliques : Louis Segond 1910 (domaine public).
- Voix : Piper, voix `fr_FR-siwis-medium` (jeu de données SIWIS, licence libre).
