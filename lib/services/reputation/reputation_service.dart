import 'package:supabase_flutter/supabase_flutter.dart';

class ReputationService {
  static final _sb = Supabase.instance.client;

  static Future<Map<String, dynamic>?> get(String userId) async {
    final res = await _sb
        .from('pro_reputation')
        .select('services_done, rating_avg, rating_count')
        .eq('pro_id', userId)
        .maybeSingle();

    return res;
  }
}
