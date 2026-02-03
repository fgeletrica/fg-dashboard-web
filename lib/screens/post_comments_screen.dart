import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_theme.dart';
import '../services/auth/auth_service.dart';
import '../services/avatar_cache.dart';

class PostCommentsScreen extends StatefulWidget {
  final String postId;
  final String? postAuthorId;
  final String? postAuthorName;
  final String? postAuthorAvatar;

  const PostCommentsScreen({
    super.key,
    required this.postId,
    this.postAuthorId,
    this.postAuthorName,
    this.postAuthorAvatar,
  });

  @override
  State<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  final _sb = Supabase.instance.client;
  final _ctrl = TextEditingController();

  bool _loading = true;
  String? _err;
  bool _sending = false;

  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    AvatarCache.init();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _myProfile() async {
    final u = AuthService.user;
    if (u == null) throw Exception('Usuário não logado');
    final prof = await _sb
        .from('profiles')
        .select('name, avatar_url')
        .eq('id', u.id)
        .maybeSingle();
    return (prof ?? {});
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });

    try {
      final res = await _sb
          .from('post_comments')
          .select(
              'id, created_at, author_id, author_name, author_avatar_url, content, like_count')
          .eq('post_id', widget.postId)
          .order('created_at', ascending: false)
          .limit(120)
          .timeout(const Duration(seconds: 12));

      _items = List<Map<String, dynamic>>.from(res as List);

      // aquece cache de avatars
      for (final it in _items) {
        final uid = (it['author_id'] ?? '').toString();
        final av = (it['author_avatar_url'] ?? '').toString().trim();
        if (uid.isNotEmpty && av.isNotEmpty) {
          AvatarCache.rememberUserId(uid, av);
        }
      }
    } catch (e) {
      _err = (e is TimeoutException)
          ? 'Timeout ao falar com o servidor (Supabase). Verifique sua internet/DNS e tente de novo.'
          : e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final u = AuthService.user;
    if (u == null) return;

    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      final prof = await _myProfile().timeout(const Duration(seconds: 12));
      final name = (prof['name'] ?? '').toString();
      final avatar = (prof['avatar_url'] ?? '').toString();

      await _sb.from('post_comments').insert({
        'post_id': widget.postId,
        'author_id': u.id,
        'author_name': name,
        'author_avatar_url': avatar,
        'content': text,
      }).timeout(const Duration(seconds: 12));

      _ctrl.clear();
      await _load();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao comentar: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border.withOpacity(.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(.85),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.white.withOpacity(.35), fontWeight: FontWeight.w700),
        filled: true,
        fillColor: AppTheme.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.border.withOpacity(.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.gold.withOpacity(.8)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text('Comentários'),
        actions: [
          IconButton(
            tooltip: 'Recarregar',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _err != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(_err!,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      )
                    : _items.isEmpty
                        ? Center(
                            child: Text(
                              'Seja o primeiro a comentar 👇',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.8),
                                  fontWeight: FontWeight.w800),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 10, 14, 10),
                              itemCount: _items.length,
                              itemBuilder: (_, i) {
                                final it = _items[i];
                                final name =
                                    (it['author_name'] ?? 'Usuário').toString();
                                final av = (it['author_avatar_url'] ?? '')
                                    .toString()
                                    .trim();
                                final content =
                                    (it['content'] ?? '').toString();
                                return Card(
                                  color: AppTheme.card,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor:
                                              Colors.white.withOpacity(.08),
                                          backgroundImage: av.isEmpty
                                              ? null
                                              : NetworkImage(av),
                                          child: av.isEmpty
                                              ? const Icon(Icons.person,
                                                  size: 18, color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w900),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _pill('💬'),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                content,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(.88),
                                                  fontWeight: FontWeight.w700,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              color: AppTheme.bg,
              border: Border(
                  top: BorderSide(color: AppTheme.border.withOpacity(.25))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800),
                    minLines: 1,
                    maxLines: 4,
                    decoration: _dec('Escreva um comentário...'),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _sending ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _sending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
