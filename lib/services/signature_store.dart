import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignatureStore {
  static const _sigKey = 'signature_base64';

  // =========================
  // Assinatura (imagem)
  // =========================

  static Future<void> saveBase64(String b64) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sigKey, b64);
  }

  static Future<Uint8List?> loadPngBytes() async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString(_sigKey);
    if (b64 == null || b64.isEmpty) return null;
    return base64Decode(b64);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sigKey);
  }

  // =========================
  // LOG JURÍDICO (imutável)
  // =========================

  static Future<void> saveLegalLog({
    required Uint8List signatureBytes,
    required String budgetId,
    required String clientName,
    String deviceInfo = 'unknown',
    String appVersion = 'unknown',
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final hash = sha256.convert(signatureBytes).toString();

    final log = {
      'budgetId': budgetId,
      'clientName': clientName,
      'signedAtIso': DateTime.now().toIso8601String(),
      'signatureHash': hash,
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
    };

    await prefs.setString(
      'signature_log_$budgetId',
      jsonEncode(log),
    );
  }

  static Future<Map<String, dynamic>?> loadLegalLog(String budgetId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('signature_log_$budgetId');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static String computeLogHash(Map<String, dynamic> log) {
    final raw = jsonEncode(log);
    return sha256.convert(utf8.encode(raw)).toString();
  }

  static Future<Map<String, dynamic>?> findLegalLogByHash(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final k in keys) {
      if (!k.startsWith("signature_log_")) continue;
      final raw = prefs.getString(k);
      if (raw == null || raw.isEmpty) continue;

      try {
        final log = jsonDecode(raw) as Map<String, dynamic>;
        final h = computeLogHash(log);
        if (h == hash) {
          // garante budgetId caso não exista
          log["budgetId"] ??= k.replaceFirst("signature_log_", "");
          return log;
        }
      } catch (_) {}
    }
    return null;
  }
}
