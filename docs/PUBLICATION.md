# Publier Lumière

Tout est gratuit, sauf le compte développeur Google Play (25 $ une seule fois), nécessaire seulement
pour le Play Store.

## 1. Le site web (GitHub Pages) — gratuit

Le jeu web est jouable hors ligne et s'installe comme une application (« Ajouter à l'écran d'accueil »),
y compris sur iPhone.

1. Sur GitHub : **Settings → Pages → Build and deployment → Source : « GitHub Actions »**.
2. Le workflow « Site web (GitHub Pages) » publie le jeu à chaque push sur `main`
   (ou à la main : onglet **Actions** → « Site web » → **Run workflow**).
3. Adresse : `https://uzziah1.github.io/lumiere/`
   - Politique de confidentialité : `https://uzziah1.github.io/lumiere/confidentialite.html`
     (c'est l'adresse à donner au Play Store).

Hors ligne : à la première visite, le jeu garde environ 5 Mo (le moteur, les dessins, les textes).
La narration est gardée au fur et à mesure qu'on écoute les histoires.

## 2. L'APK à partager — gratuit

À chaque étiquette de version, le workflow « Publication Android » crée une **Release** GitHub avec
l'APK et l'AAB :

```bash
git tag v0.4.0
```

```bash
git push origin v0.4.0
```

Le numéro de version de l'appli se règle dans `app/pubspec.yaml` (`version: 0.4.0+4` : le nombre après
le `+` doit augmenter à chaque publication sur le Play Store) et dans `app/lib/version.dart`.

Sans clé de publication, l'APK est signé avec une clé de test : il s'installe sur n'importe quel
téléphone (autoriser les « sources inconnues »), mais le Play Store le refuse.

## 3. La clé de publication (pour le Play Store)

**À faire une seule fois, et à garder précieusement** : sans cette clé, impossible de mettre à jour
l'appli sur le Play Store. Ne jamais la commiter ni l'envoyer par message.

1. Créer la clé (Git Bash ; `keytool` est fourni avec Java ou Android Studio) :

   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. La convertir en texte pour GitHub :

   ```bash
   base64 -w 0 upload-keystore.jks > keystore-base64.txt
   ```

3. Sur GitHub : **Settings → Secrets and variables → Actions → New repository secret**, créer :
   - `ANDROID_KEYSTORE_BASE64` : le contenu de `keystore-base64.txt`
   - `ANDROID_KEYSTORE_PASSWORD` : le mot de passe du fichier de clés
   - `ANDROID_KEY_ALIAS` : `upload`
   - `ANDROID_KEY_PASSWORD` : le mot de passe de la clé
4. Supprimer `keystore-base64.txt`, ranger `upload-keystore.jks` et les mots de passe en lieu sûr
   (deux copies, hors de l'ordinateur).

Pour construire une version signée sur ton ordinateur, crée `app/android/key.properties` (ignoré par git) :

```
storeFile=chemin/vers/upload-keystore.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

## 4. Le Play Store

1. Créer un compte développeur Google Play (25 $).
2. Créer l'application « Lumière — la Bible en jeux », langue française, gratuite.
3. **Identifiant** : `org.lumiere.lumiere` (défini dans `app/android/app/build.gradle.kts`). Il ne
   pourra plus changer après la première publication : le modifier avant si besoin.
4. Programme **« Familles »** : public cible 4 à 12 ans ; questionnaire de contenu (aucune violence,
   aucun achat, aucune publicité) ; « Sécurité des données » : **aucune donnée collectée ni partagée**.
5. Politique de confidentialité : l'adresse GitHub Pages ci-dessus. Avant la publication, compléter
   l'adresse de contact dans `app/lib/parents/privacy.dart` (puis régénérer `docs/confidentialite.md`
   et `app/web/confidentialite.html` ; le test `privacy_test.dart` vérifie qu'ils sont identiques).
6. Envoyer le fichier `.aab` de la Release en « test interne », puis en production.

## 5. Avant chaque publication

- `flutter analyze` et `flutter test` verts (la CI le vérifie).
- Versets vérifiés dans une Louis Segond 1910, textes relus par un pasteur.
- Tester l'APK sur un vrai téléphone Android d'entrée de gamme.
