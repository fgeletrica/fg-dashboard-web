import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppProfile {
  final String name;
  final String phone;
  final String email;
  final String company;
  final String avatarB64; // logo/foto
  final String coverB64; // capa/banner
  final String specialty;
  final String level;
  final String bio;

  AppProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    required this.avatarB64,
    required this.coverB64,
    required this.specialty,
    required this.level,
    required this.bio,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'company': company,
        'avatarB64': avatarB64,
        'coverB64': coverB64,
        'specialty': specialty,
        'level': level,
        'bio': bio,
      };

  static AppProfile fromJson(Map<String, dynamic> j) => AppProfile(
        name: (j['name'] ?? 'Felype Guimarães').toString(),
        phone: (j['phone'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        company: (j['company'] ?? 'FG Elétrica').toString(),
        avatarB64: (j['avatarB64'] ?? '').toString(),
        coverB64: (j['coverB64'] ?? '').toString(),
        specialty: (j['specialty'] ?? 'Autônomo').toString(),
        level: (j['level'] ?? 'Iniciante').toString(),
        bio: (j['bio'] ?? '').toString(),
      );
}

class ProfileStore {
  static const _k = 'profile_v2';

  static AppProfile _defaults() => AppProfile(
        name: 'Felype Guimarães',
        phone: '',
        email: '',
        company: 'FG Elétrica',
        avatarB64: '',
        coverB64: '',
        specialty: 'Autônomo',
        level: 'Iniciante',
        bio: '',
      );

  static Future<AppProfile> get() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_k);
    if (raw == null || raw.trim().isEmpty) return _defaults();
    try {
      final j = jsonDecode(raw);
      if (j is Map) return AppProfile.fromJson(j.cast<String, dynamic>());
    } catch (_) {}
    return _defaults();
  }

  static Future<void> set({
    required String name,
    required String phone,
    required String email,
    required String company,
    String? avatarB64,
    String? coverB64,
    String? specialty,
    String? level,
    String? bio,
  }) async {
    final p = await SharedPreferences.getInstance();
    final old = await get();

    final data = AppProfile(
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      company: company.trim(),
      avatarB64: (avatarB64 ?? old.avatarB64).trim(),
      coverB64: (coverB64 ?? old.coverB64).trim(),
      specialty: (specialty ?? old.specialty).trim(),
      level: (level ?? old.level).trim(),
      bio: (bio ?? old.bio).trim(),
    );

    await p.setString(_k, jsonEncode(data.toJson()));
  }

  static Future<void> setAvatar(String b64) async {
    final old = await get();
    await set(
      name: old.name,
      phone: old.phone,
      email: old.email,
      company: old.company,
      avatarB64: b64,
      coverB64: old.coverB64,
      specialty: old.specialty,
      level: old.level,
      bio: old.bio,
    );
  }

  static Future<void> setCover(String b64) async {
    final old = await get();
    await set(
      name: old.name,
      phone: old.phone,
      email: old.email,
      company: old.company,
      avatarB64: old.avatarB64,
      coverB64: b64,
      specialty: old.specialty,
      level: old.level,
      bio: old.bio,
    );
  }

  static Future<bool> isProfileComplete() async {
    final p = await get();
    return p.name.trim().isNotEmpty && p.company.trim().isNotEmpty;
  }

  // ===== Company profile (compat) =====
  static const _kCompany = 'company_profile_v1';

  static Future<Map<String, dynamic>> loadCompanyProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCompany);
    if (raw == null || raw.trim().isEmpty) {
      return <String, dynamic>{
        'companyName': 'FG Elétrica',
        'cnpj': '',
        'address': '',
        'phone': '',
        'email': '',
        'logoB64': '',
      };
    }
    try {
      final j = jsonDecode(raw);
      if (j is Map) return j.cast<String, dynamic>();
    } catch (_) {}
    return <String, dynamic>{
      'companyName': 'FG Elétrica',
      'cnpj': '',
      'address': '',
      'phone': '',
      'email': '',
      'logoB64': '',
    };
  }

  static Future<void> saveCompanyProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCompany, jsonEncode(data));
  }
}
