import 'package:supabase_flutter/supabase_flutter.dart';

class RankingService {
  static final _sb = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> weekly() async {
    final res = await _sb
        .from('pro_weekly_rank')
        .select('*')
        .order('score', ascending: false)
        .limit(20);

    return List<Map<String, dynamic>>.from(res as List);
  }
}
