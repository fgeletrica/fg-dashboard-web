import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarCache {
  static const _k = 'fg_avatar_cache_v1';

  static bool _inited = false;
  static final Map<String, String> _byPhone = {};
  static final Map<String, String> _byUserId = {};

  static Future<void> init() async {
    if (_inited) return;
    _inited = true;
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_k);
      if (raw == null || raw.trim().isEmpty) return;

      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      final Map<String, dynamic> p =
          (data['byPhone'] as Map?)?.cast<String, dynamic>() ?? {};
      final Map<String, dynamic> u =
          (data['byUserId'] as Map?)?.cast<String, dynamic>() ?? {};

      _byPhone
        ..clear()
        ..addAll(p.map((k, v) => MapEntry(k, (v ?? '').toString())));
      _byUserId
        ..clear()
        ..addAll(u.map((k, v) => MapEntry(k, (v ?? '').toString())));
    } catch (_) {}
  }

  static String _digits(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9]'), '');

  static String getLocalByPhone(String phone) {
    final d = _digits(phone);
    if (d.isEmpty) return '';
    return (_byPhone[d] ?? '').trim();
  }

  static String getLocalByUserId(String userId) {
    final id = userId.trim();
    if (id.isEmpty) return '';
    return (_byUserId[id] ?? '').trim();
  }

  static Future<void> rememberPhone(String phone, String url) async {
    final d = _digits(phone);
    final u = url.trim();
    if (d.isEmpty || u.isEmpty) return;
    _byPhone[d] = u;
    await _save();
  }

  static Future<void> rememberUserId(String userId, String url) async {
    final id = userId.trim();
    final u = url.trim();
    if (id.isEmpty || u.isEmpty) return;
    _byUserId[id] = u;
    await _save();
  }

  static Future<void> warm(BuildContext context, String url) async {
    final u = url.trim();
    if (u.isEmpty) return;
    try {
      await precacheImage(NetworkImage(u), context);
    } catch (_) {}
  }

  static Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = jsonEncode({
        'byPhone': _byPhone,
        'byUserId': _byUserId,
      });
      await sp.setString(_k, raw);
    } catch (_) {}
  }
}
