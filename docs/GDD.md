# Lumière — Document de conception du jeu (GDD)

> Version 0.2 — novembre 2026. Document vivant : on le met à jour à chaque décision.

## 1. Vision

**Lumière** est un jeu vidéo gratuit, sans publicité et sans collecte de données, qui fait découvrir
la Bible aux enfants de 4 à 12 ans, sur téléphone (Android d'abord) et sur le web.

L'enfant voyage sur une carte du monde biblique, accompagné de **Colombe**, une petite colombe guide.
Chaque histoire se vit (récit animé et raconté), se joue (mini-jeux) et se retient (verset, autocollant).

Public : familles et églises **évangéliques / protestantes** d'Afrique francophone, puis toute la francophonie.

**Promesse aux parents** : « Un jeu beau, sûr et fidèle à la Bible, que votre enfant réclame. »

## 2. Principes (non négociables)

1. **Fidèle à la Bible.** Récits simplifiés mais jamais inventés sur le fond ; référence toujours affichée
   (« Genèse 6–9 »). Versets cités en Louis Segond 1910 (domaine public). Pas d'apocryphes.
2. **Respect théologique évangélique.** Dieu n'est jamais dessiné comme un personnage : il est lumière,
   voix, rayons. Jésus peut être représenté, avec douceur et dignité. Textes relus par un pasteur avant publication.
3. **Aucun échec qui punit.** Une erreur = un indice de Colombe, jamais un écran rouge ni une perte.
4. **Sûr pour l'enfant.** Pas de pub, pas de compte, pas de chat, pas de lien externe hors espace parents,
   aucune donnée envoyée. Conforme à la politique « Familles » de Google Play.
5. **Hors ligne d'abord, léger.** Fonctionne sans réseau après installation. Cible : Android 2 Go de RAM,
   appli < 60 Mo pour le premier lot d'histoires, 60 images/s sur les téléphones d'entrée de gamme.
6. **Beau par cohérence.** Un style artistique unique, tenu partout (voir § 7).
7. **Gratuit pour toujours.** Zéro budget : uniquement des outils et ressources libres ou que nous produisons.

## 3. Les trois âges

Choisi par le parent (modifiable à tout moment), un profil par enfant (jusqu'à 4 sur l'appareil).

| | **Agneaux** (4–6 ans) | **Bergers** (7–9 ans) | **Explorateurs** (10–12 ans) |
|---|---|---|---|
| Lecture | Aucune : tout est narré | Phrases courtes + narration | Lecture autonome, narration facultative |
| Gestes | Toucher, glisser | + tracer, associer | + saisie, choix multiples, chrono facultatif |
| Mini-jeux | 2–3 par histoire, très guidés | 3–4 | 4–5, plus difficiles |
| Versets | Une phrase-clé écoutée | Verset court à reconstituer | Verset complet + référence (livre, chapitre) |
| Contenu en plus | — | « Le savais-tu ? » | Cartes, contexte historique, liens entre histoires |

Une même histoire sert les trois âges : seuls le texte, la narration et la difficulté des jeux changent.

## 4. Boucle de jeu

```
Carte du monde ──► Île (histoire) ──► 1. Récit animé interactif (2–4 min)
      ▲                                2. Mini-jeux (au choix, dans l'ordre suggéré)
      │                                3. Verset à retenir
      │                                4. Récompenses : étoiles, autocollant, élément du trésor
      └──────── nouvelle île débloquée ◄──┘
```

- **Session type** : 5 à 10 minutes (une histoire). Le parent peut fixer une limite quotidienne.
- **Étoiles** : 1 par étape réussie (récit, jeux, verset), 3 à 5 par histoire. Elles débloquent les îles suivantes
  (assez souples pour qu'aucun enfant ne reste bloqué).
- **Album d'autocollants** : un autocollant animé par histoire terminée + autocollants bonus.
- **Le trésor** (méta-progression) : l'enfant construit et décore sa propre **arche de Noé**, puis son **jardin**
  et son **village** au fil des grands chapitres. Chaque histoire rapporte un animal, une plante ou un objet à placer.
  C'est le « pourquoi je reviens demain ».

## 5. Le récit animé interactif

- Découpé en **scènes** (5 à 10 par histoire). Chaque scène : décor en couches (parallaxe), personnages,
  narration audio, sous-titres (Bergers / Explorateurs), et **une interaction** qui fait avancer le récit
  (faire monter les animaux, ouvrir la mer du doigt, lancer la pierre de David…).
- Rien n'avance tant que la narration n'est pas finie ; « toucher pour continuer » clignote doucement ensuite.
- Bouton « réécouter » sur chaque scène. Pas de chronomètre.

## 6. Mini-jeux (moteur commun, contenu par histoire)

Chaque type de jeu est un composant générique alimenté par les données de l'histoire.

| Type | Principe | Âges |
|---|---|---|
| **Chronologie** | Remettre 3 à 6 images de l'histoire dans l'ordre | Tous |
| **Cherche et trouve** | Trouver 5 à 10 objets cachés dans une grande scène | Tous |
| **Memory** | Retrouver les paires (personnages, objets) | Tous |
| **Puzzle** | Reconstituer une illustration (4 à 24 pièces) | Tous |
| **Associe** | Relier personnage ↔ objet / action (Moïse ↔ bâton) | Bergers + |
| **Quiz illustré** | Question narrée, 2 à 4 réponses en images ou texte | Tous (adapté) |
| **Verset en morceaux** | Glisser les mots dans l'ordre, puis la référence | Bergers + |
| **Jeu d'action** propre à l'histoire | Ex. guider les animaux deux par deux, le filet de pêche miraculeuse | Tous |

Le **jeu d'action** est le seul spécifique à une histoire : on en fait un pour les histoires phares seulement.

## 7. Direction artistique — « papier découpé lumineux »

Contrainte : zéro budget, pas d'illustrateur. On choisit donc un style **que le code peut produire parfaitement**
plutôt qu'un style dessiné à la main qu'on imiterait mal.

- **Papier découpé** : formes vectorielles simples aux bords arrondis, empilées en couches, chaque couche portant
  une ombre douce (effet papier posé sur papier). Grain de papier léger en surimpression.
- **Lumière** (le nom du jeu) : dégradés chauds, halos, poussière dorée en particules, rayons. Dieu = lumière.
- **Personnages** : silhouettes rondes et expressives (corps en goutte, tête ronde, grands yeux simples,
  pas de bouche détaillée), peaux brunes de différents tons, vêtements colorés. Ils s'animent par
  respiration, rebond, clignement d'yeux, inclinaison : très vivants pour peu de détails.
- **Palette** : aube (pêche, rose, or), désert (ocre, sable, terre cuite), nuit (indigo, bleu profond, étoiles),
  eau (turquoise, bleu lagon). Chaque histoire a sa palette dominante.
- **Typographie** (libre, OFL) : titres en police ronde et chaleureuse (ex. *Baloo 2* ou *Fredoka*),
  texte très lisible (*Andika*, conçue pour les jeunes lecteurs et le français).
- **Interface** : gros boutons (≥ 64 px), icônes plutôt que mots, retours sonores et visuels à chaque toucher.

Références d'ambiance (pour le style, pas à copier) : livres pop-up, ombres chinoises, illustration « paper craft ».

Production : les éléments sont des **SVG écrits par nous** (formes, décors, personnages modulaires : un même
corps, plusieurs têtes, vêtements, accessoires), assemblés et animés dans le moteur.

## 8. Son et voix

- **Narration** : voix française synthétisée hors ligne avec **Piper** (moteur libre, voix neuronales françaises),
  générée en fichiers audio au moment du build, donc aucun réseau nécessaire en jeu. Plus tard : remplacement
  progressif par de vraies voix bénévoles (conteuse d'église, enfants) enregistrées au téléphone.
- **Musique** : synthétisée en code (kalimba, balafon, shaker, nappes), douce, une boucle par type d'écran (accueil, carte, récit, jeux).
- **Bruitages** : packs CC0 (Kenney, Freesound CC0).
- Réglages séparés : narration, musique, effets.

## 9. Contenu

### Lot 1 (MVP) — Ancien Testament
1. La Création (Genèse 1–2)
2. Adam et Ève dans le jardin (Genèse 2–3)
3. **Noé et l'arche** (Genèse 6–9) ← prototype
4. Abraham et les étoiles (Genèse 12, 15, 21)
5. Joseph et ses frères (Genèse 37–45)
6. Moïse et la traversée de la mer (Exode 2–14)
7. David et Goliath (1 Samuel 17)
8. Jonas et le grand poisson (Jonas 1–4)

### Lot 2 — Nouveau Testament
Naissance de Jésus · Jésus enfant au temple · Le baptême de Jésus · Jésus calme la tempête ·
La multiplication des pains · Zachée · Le bon Samaritain · Le fils prodigue · Pâques (mort et résurrection) ·
La Pentecôte

### Lot 3 — Les héros de la foi (fait en L6)
Les murs de Jéricho · Gédéon · Ruth · Samuel appelé · Élie · Daniel dans la fosse aux lions · Esther
(et les noces de Cana, ajoutées au lot 2).

### Lot 4 et suivants
Néhémie · Lazare · Paul sur le chemin de Damas · Paul et le naufrage…

### Format d'une histoire (données, pas de code)
Chaque histoire est un dossier `content/stories/<id>/` : `story.json` (métadonnées, références bibliques,
scènes, textes par âge, mini-jeux et leurs données, récompenses), éléments graphiques, audio généré.
Ajouter une histoire = ajouter un dossier, sans toucher au moteur.

## 10. Espace parents

- Accès par une **barrière parentale** (calcul simple dicté en lettres, ex. « sept fois huit »).
- Profils enfants (prénom ou surnom + avatar, âge), progression par histoire, temps de jeu.
- Limite de temps quotidienne facultative (Colombe annonce gentiment la fin : « On se retrouve demain ! »).
- Réglages audio, langue, sous-titres. Lien « À propos » : crédits, licences, politique de confidentialité.

## 11. Technique

| Domaine | Choix |
|---|---|
| Moteur | **Flutter** (stable) + **Flame** (jeu 2D) |
| Plates-formes | Android (Play Store), web (PWA installable, aussi sur iPhone). iOS natif plus tard. Jeu à l'horizontale (verrouillé sur téléphone, mise en page souple sur le web) |
| Graphismes | SVG vectoriels produits par nous (`flame_svg` / `flutter_svg`), effets Flame (particules, tweens, parallaxe) |
| Audio | `flame_audio`, narration Piper pré-générée (OGG/MP3) |
| Sauvegarde | Locale uniquement (profils, progression) |
| État | Riverpod ; navigation go_router hors scènes de jeu |
| Serveur | **Aucun** pour la V1 : rien à héberger ni à payer, aucune donnée d'enfant |
| Hébergement web | Gratuit (GitHub Pages, Netlify ou Vercel) |
| Tests | `flutter analyze`, `flutter test` (logique, données des histoires validées automatiquement, golden tests des écrans) |
| CI | GitHub Actions : analyse, tests, build web + APK |

Seuls coûts éventuels : compte développeur Google Play (25 $ une seule fois) quand on publiera. En attendant,
le web et l'APK téléchargeable sont gratuits.

## 12. Feuille de route

| Étape | Contenu | Livrable |
|---|---|---|
| **L0 — Socle** ✅ | Projet Flutter + Flame, structure, thème « papier découpé », typo, CI, page de démarrage animée avec Colombe | Appli qui s'ouvre, belle, sur Android et web |
| **L1 — Noé (tranche verticale)** ✅ | Récit animé complet, 3 mini-jeux (chronologie, cherche et trouve, memory), verset, récompenses, narration Piper | Une histoire parfaite de bout en bout |
| **L2 — Carte et progression** ✅ | Carte du monde, îles, étoiles, profils, sauvegarde, trois âges | Le jeu « tient debout » |
| **L3 — Lot 1** ✅ | 7 histoires de plus, tous les types de mini-jeux, album d'autocollants, l'arche-trésor | MVP jouable |
| **L4 — Parents et publication** ✅ | Espace parents, limites de temps, accessibilité, page de confidentialité, PWA, APK | Bêta publique |
| **L5 — Nouveau Testament** | Lot 2, jardin-trésor | V1 |
| Plus tard | Voix bénévoles, langues africaines en audio (mooré, dioula, wolof…), iOS natif, mode église/classe | |

Une étape à la fois, validée par Uzziah avant la suivante.

## 13. Décisions prises

| Date | Décision |
|---|---|
| nov. 2026 | Public 4–12 ans, trois âges ; sensibilité évangélique / protestante |
| nov. 2026 | Entièrement gratuit, aucun budget : outils et ressources libres uniquement |
| nov. 2026 | Flutter + Flame, aucun serveur en V1 |
| nov. 2026 | Style « papier découpé lumineux » dessiné en code ; Colombe porte le rameau d'olivier |
| nov. 2026 | Jeu à l'horizontale ; polices Fredoka (titres) et Andika (texte) intégrées à l'appli |
| nov. 2026 | Narration : voix Piper « siwis » (féminine, française), un peu ralentie ; sous-titres sauf pour les Agneaux |
| nov. 2026 | Bruitages synthétisés en code (aucune banque de sons) |
| nov. 2026 | Noé : verset Genèse 9.13 |
| nov. 2026 | Voix de narration définitive : Piper « siwis » |
| nov. 2026 | Profils : 4 au plus, prénom + âge + animal ; modifier/supprimer derrière la barrière parentale |
| nov. 2026 | Carte : une mer et 8 îles (lot 1) ; une île s'ouvre avec 3 étoiles sur la précédente ; histoires pas encore faites affichées « bientôt » ; une île déjà commencée reste ouverte |
| nov. 2026 | Lot 1 : six scènes par histoire (Noé : huit) ; versets Genèse 1.1, 3.9, 6–9 (9.13), 15.6, 50.20, Exode 14.14, Psaume 23.1, Jonas 2.10 |
| nov. 2026 | Arche-trésor : un ami par histoire terminée (girafe, lapin, colombe, mouton, chameau, grenouille, lion, poisson) ; l'enfant le touche pour le faire sauter (pas encore de placement libre) |
| nov. 2026 | Espace parents : progression, réglages (voix, bruitages, sous-titres, animations, grand texte), limite quotidienne 15 à 90 min avec « À demain » et temps offert par un parent |
| nov. 2026 | Publication gratuite : jeu web hors ligne sur GitHub Pages, APK sur les Releases GitHub ; Play Store plus tard (25 $) |
| nov. 2026 | Récits délicats (la chute, Goliath, la mer qui se referme) racontés sans peur : on montre la chute de Goliath « face contre terre », jamais de violence |
| nov. 2026 | Musique : quatre boucles synthétisées en code (kalimba, balafon, shaker), une par type d'écran ; elle baisse pendant la narration ; réglable chez les parents |
| nov. 2026 | Lot 2 (Nouveau Testament) : six scènes par histoire ; versets Luc 2.11, Luc 2.52, Matthieu 3.17, Marc 4.41, Jean 6.35, Luc 19.10, Luc 10.27, Luc 15.24, Luc 24.6, Actes 1.8 (début) |
| nov. 2026 | Pâques : la croix vue de loin, en silhouette, au crépuscule ; aucun détail de souffrance ; on termine sur le tombeau vide et Jésus vivant |
| nov. 2026 | Le lot 2 s'ouvre dès le départ (sa première île est ouverte, comme celle du lot 1) |
| nov. 2026 | Jardin-trésor : un ami par histoire du Nouveau Testament (étoile, rouleau, oiseau, raisin, bateau, pain, arbre, âne, cochon, fleur, flamme) ; on passe d'un trésor à l'autre par des boutons |
| nov. 2026 | Lot 3 « Les héros de la foi » : Jéricho, Gédéon, Ruth, Samuel, Élie, Daniel, Esther, placés entre l'Ancien et le Nouveau Testament sur la carte (ordre biblique) ; sa première île est ouverte d'emblée |
| nov. 2026 | Les noces de Cana, choisies avec le lot 3, vont dans le Nouveau Testament, juste après le baptême |
| nov. 2026 | Coffre au trésor du lot 3 : un souvenir par histoire (trompette, torche, épi, lampe, corbeau, lion, sceptre) |
| nov. 2026 | Lot 3 : versets Josué 1.9, Juges 6.12, Ruth 1.16, 1 Samuel 3.10, 1 Rois 18.39, Daniel 6.23, Esther 4.14 ; Cana : Jean 2.5 |
| nov. 2026 | L7 : deux nouveaux jeux, le puzzle de la scène (4, 6 ou 9 pièces selon l'âge, on échange deux pièces d'une touche, modèle à côté) et le quiz illustré (questions lues, réponses en images, une erreur efface seulement l'image) |
| nov. 2026 | Rotation : chaque histoire propose 3 jeux sur 5 (chronologie, cache-cache, memory, puzzle, quiz) plus le verset, toujours 5 étoiles ; les étoiles déjà gagnées à un jeu retiré restent comptées |

## 14. Questions ouvertes

- Nom définitif et disponibilité (stores, domaine).
- Relecteur doctrinal (pasteur) pour les textes ; vérifier le texte exact des versets dans une Louis Segond 1910
  (en particulier Genèse 50.20 et Jonas 2.10 : citation partielle et numérotation ; Luc 2.11, Matthieu 3.17,
  Luc 15.24 et Actes 1.8 sont des citations partielles, avec une majuscule au début ; Josué 1.9 et Juges 6.12
  aussi ; Daniel 6.23 suit la numérotation de la Segond, décalée d'un verset par rapport aux Bibles anglaises).
- Bénévoles pour les voix réelles, plus tard.
