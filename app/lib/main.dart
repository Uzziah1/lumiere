import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'save/game_state.dart';
import 'save/save_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    // Sur téléphone, le jeu se joue à l'horizontale et en plein écran.
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  // Profils et progression : sauvegardés sur l'appareil uniquement.
  final game = GameState(PrefsSaveStore());
  await game.load();
  runApp(LumiereApp(gameState: game));
}
