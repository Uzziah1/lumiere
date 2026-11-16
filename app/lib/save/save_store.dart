import 'package:shared_preferences/shared_preferences.dart';

/// Où la sauvegarde est rangée (une seule chaîne JSON).
abstract class SaveStore {
  Future<String?> read();

  Future<void> write(String data);
}

/// Sauvegarde sur l'appareil (préférences Android, stockage local du navigateur).
class PrefsSaveStore implements SaveStore {
  static const key = 'lumiere.save';

  @override
  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<void> write(String data) async => (await SharedPreferences.getInstance()).setString(key, data);
}

/// Sauvegarde en mémoire (tests, ou repli si le stockage est indisponible).
class MemorySaveStore implements SaveStore {
  MemorySaveStore([this.data]);

  String? data;
  int writes = 0;

  @override
  Future<String?> read() async => data;

  @override
  Future<void> write(String data) async {
    this.data = data;
    writes++;
  }
}
