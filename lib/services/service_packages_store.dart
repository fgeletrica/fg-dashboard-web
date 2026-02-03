import 'package:shared_preferences/shared_preferences.dart';

class ServicePackagesStore {
  static const _key = 'service_packages';

  static Future<Map<String, List<Map<String, dynamic>>>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null) return {};
    return Map<String, List<Map<String, dynamic>>>.from({});
  }

  static Future<void> save(Map<String, List<Map<String, dynamic>>> data) async {
    final sp = await SharedPreferences.getInstance();
    sp.setString(_key, data.toString());
  }
}
