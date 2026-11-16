/// Politique de confidentialité de Lumière (aussi publiée dans
/// `docs/confidentialite.md` et `app/web/confidentialite.html` : garder les
/// trois textes identiques).
const privacySections = <(String, String)>[
  (
    'En résumé',
    'Lumière ne collecte aucune donnée. Il n’y a ni compte, ni publicité, ni statistiques, ni partage avec qui que ce soit. '
        'Tout ce que l’enfant fait dans le jeu reste sur cet appareil.',
  ),
  (
    'Ce qui est enregistré sur l’appareil',
    'Pour que l’enfant retrouve sa progression, le jeu enregistre sur l’appareil uniquement : le prénom ou surnom choisi, '
        'la tranche d’âge, l’animal de l’avatar, les étoiles et autocollants gagnés, le temps de jeu des 14 derniers jours '
        'et les réglages de l’espace parents. Ces informations ne quittent jamais l’appareil.',
  ),
  (
    'Ce qui n’est jamais fait',
    'Aucune information n’est envoyée sur Internet. Le jeu ne contient aucune publicité, aucun outil de mesure d’audience, '
        'aucun lien vers les réseaux sociaux et aucun achat. Il fonctionne entièrement hors ligne.',
  ),
  (
    'Autorisations',
    'Sur Android, l’application ne demande aucune autorisation : ni Internet, ni appareil photo, ni micro, ni localisation, '
        'ni contacts.',
  ),
  (
    'Effacer les données',
    'Dans l’espace parents, « Enfants » puis « Modifier » permet de supprimer un profil et toute sa progression. '
        'Désinstaller l’application (ou effacer les données du site dans le navigateur) efface tout.',
  ),
  (
    'Enfants',
    'Lumière est conçu pour les enfants de 4 à 12 ans et respecte la politique « Familles » de Google Play. '
        'L’espace parents est protégé par une question à laquelle un adulte répond facilement.',
  ),
  (
    'Contact',
    'Pour toute question : l’équipe Lumière, Ouagadougou (Burkina Faso). Adresse de contact à compléter avant la publication.',
  ),
];

/// Crédits et licences.
const credits = <(String, String)>[
  ('Textes bibliques', 'Louis Segond 1910 (domaine public). Récits simplifiés pour les enfants.'),
  ('Voix', 'Synthèse vocale libre Piper, voix française « siwis » (jeu de données SIWIS).'),
  ('Polices', 'Fredoka et Andika (SIL Open Font License).'),
  ('Dessins, sons et musique', 'Tous les dessins et bruitages sont créés en code par l’équipe Lumière.'),
  ('Logiciel', 'Flutter, Flame, go_router, audioplayers, shared_preferences (licences libres).'),
];
