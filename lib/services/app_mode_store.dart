import 'package:shared_preferences/shared_preferences.dart';

class AppModeStore {
  static const _k = 'app_mode_v1'; // 'res' | 'ind'

  static Future<String?> getMode() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_k);
    return (v == null || v.trim().isEmpty) ? null : v;
  }

  static Future<void> setMode(String mode) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k, mode);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_k);
  }
}
