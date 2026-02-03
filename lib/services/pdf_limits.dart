import 'package:meu_ajudante_fg/services/pro_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfLimits {
  // FREE: 3 PDFs por mês
  static const int freePerMonth = 3;

  static String _keyMonth(int year, int month) => 'pdf_free_${year}_$month';

  static Future<int> _getCountThisMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = _keyMonth(now.year, now.month);
    return prefs.getInt(key) ?? 0;
  }

  static Future<void> _setCountThisMonth(int v) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = _keyMonth(now.year, now.month);
    await prefs.setInt(key, v);
  }

  static Future<int> freeRemainingThisMonth() async {
    final hasPro = await ProGuard.hasPro();
    if (hasPro) return 999999;

    final used = await _getCountThisMonth();
    final left = freePerMonth - used;
    return left < 0 ? 0 : left;
  }

  static Future<void> markFreePdfGenerated() async {
    final hasPro = await ProGuard.hasPro();
    if (hasPro) return;

    final used = await _getCountThisMonth();
    await _setCountThisMonth(used + 1);
  }
}
