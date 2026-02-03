import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsService {
  static final _sb = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> list(String postId) async {
    final res = await _sb
        .from('post_comments')
        .select('*')
        .eq('post_id', postId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res as List);
  }

  static Future<void> add({
    required String postId,
    required String authorId,
    required String name,
    required String avatar,
    required String content,
  }) async {
    await _sb.from('post_comments').insert({
      'post_id': postId,
      'author_id': authorId,
      'author_name': name,
      'author_avatar_url': avatar,
      'content': content,
    });
  }
}
