import 'local_store.dart';

class SubscriptionAccess {
  // tier: 'free' | 'pro' | 'premium'
  static Future<String> getTier() async {
    final p = await LocalStore.getProfile();
    final tier = (p['tier'] ?? 'free').toString();
    if (tier != 'pro' && tier != 'premium') return 'free';
    return tier;
  }

  static Future<void> setTier(String tier) async {
    final p = await LocalStore.getProfile();
    p['tier'] = tier;
    await LocalStore.setProfile(p);
  }

  static Future<bool> hasPro() async {
    final t = await getTier();
    return t == 'pro' || t == 'premium';
  }

  static Future<bool> hasPremium() async {
    final t = await getTier();
    return t == 'premium';
  }
}
