import 'package:shared_preferences/shared_preferences.dart';

class ServiceFavoritesStore {
  static const _key = 'fav_services';

  static Future<Set<String>> load() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_key)?.toSet() ?? {};
  }

  static Future<void> toggle(String name) async {
    final sp = await SharedPreferences.getInstance();
    final set = sp.getStringList(_key)?.toSet() ?? {};
    set.contains(name) ? set.remove(name) : set.add(name);
    sp.setStringList(_key, set.toList());
  }

  static Future<bool> isFav(String name) async {
    final s = await load();
    return s.contains(name);
  }
}
