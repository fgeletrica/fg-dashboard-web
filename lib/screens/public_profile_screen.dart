import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_theme.dart';
import '../services/auth/auth_service.dart';
import '../services/avatar_cache.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  final String? fallbackName;
  final String? fallbackAvatar;

  const PublicProfileScreen({
    super.key,
    required this.userId,
    this.fallbackName,
    this.fallbackAvatar,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen>
    with SingleTickerProviderStateMixin {
  final _sb = Supabase.instance.client;

  bool _loading = true;
  String? _err;

  Map<String, dynamic> _p = {};
  int _posts = 0;
  int _followers = 0;
  int _following = 0;

  bool _checkingFollow = false;
  bool _isFollowing = false;

  List<Map<String, dynamic>> _postsGrid = [];

  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    AvatarCache.init();
    _loadAll();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _err = null;
    });

    try {
      final prof = await _sb
          .from('public_profiles')
          .select('id, role, name, city, avatar_url, bio, profession')
          .eq('id', widget.userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 12));

      _p = prof ?? {};

      final av = (_p['avatar_url'] ?? '').toString().trim();
      if (av.isNotEmpty) {
        AvatarCache.rememberUserId(widget.userId, av);
        if (mounted) await AvatarCache.warm(context, av);
      }

      await _loadFollowState();
      await _loadCounts();
      await _loadPostsGrid();
    } catch (e) {
      _err = (e is TimeoutException)
          ? 'Timeout ao falar com o servidor (Supabase). Verifique sua internet/DNS e tente de novo.'
          : e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCounts() async {
    // posts
    try {
      final p = await _sb
          .from('posts')
          .select('id')
          .eq('author_id', widget.userId)
          .limit(2000)
          .timeout(const Duration(seconds: 12));
      _posts = (p as List).length;
    } catch (_) {
      _posts = 0;
    }

    // followers / following
    try {
      final a = await _sb
          .from('user_follows')
          .select('follower_id')
          .eq('following_id', widget.userId)
          .limit(5000)
          .timeout(const Duration(seconds: 12));
      _followers = (a as List).length;

      final b = await _sb
          .from('user_follows')
          .select('following_id')
          .eq('follower_id', widget.userId)
          .limit(5000)
          .timeout(const Duration(seconds: 12));
      _following = (b as List).length;
    } catch (_) {
      _followers = 0;
      _following = 0;
    }
  }

  Future<void> _loadPostsGrid() async {
    try {
      final r = await _sb
          .from('posts')
          .select('id, media_url')
          .eq('author_id', widget.userId)
          .order('created_at', ascending: false)
          .limit(30)
          .timeout(const Duration(seconds: 12));

      _postsGrid = List<Map<String, dynamic>>.from(r as List);
    } catch (_) {
      _postsGrid = [];
    }
  }

  Future<void> _loadFollowState() async {
    final me = AuthService.user;
    if (me == null || me.id == widget.userId) {
      _isFollowing = false;
      return;
    }

    try {
      final row = await _sb
          .from('user_follows')
          .select('follower_id')
          .eq('follower_id', me.id)
          .eq('following_id', widget.userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 12));
      _isFollowing = row != null;
    } catch (_) {
      _isFollowing = false;
    }
  }

  Future<void> _toggleFollow() async {
    final me = AuthService.user;
    if (me == null || me.id == widget.userId) return;

    setState(() => _checkingFollow = true);
    try {
      if (_isFollowing) {
        await _sb
            .from('user_follows')
            .delete()
            .eq('follower_id', me.id)
            .eq('following_id', widget.userId)
            .timeout(const Duration(seconds: 12));
        _isFollowing = false;
      } else {
        await _sb.from('user_follows').insert({
          'follower_id': me.id,
          'following_id': widget.userId,
        }).timeout(const Duration(seconds: 12));
        _isFollowing = true;
      }

      await _loadCounts();
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _checkingFollow = false);
    }
  }

  void _openAvatar(String url) {
    final u = url.trim();
    if (u.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.9),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(u, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  void _openProfile(String userId, String name, String avatar) {
    final id = userId.trim();
    if (id.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(
          userId: id,
          fallbackName: name,
          fallbackAvatar: avatar,
        ),
      ),
    );
  }

  Future<void> _openFollowList({required bool followers}) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bg,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (_, controller) {
          return _FollowListSheet(
            controller: controller,
            userId: widget.userId,
            title: followers ? 'Seguidores' : 'Seguindo',
            isFollowers: followers,
            openProfile: _openProfile,
          );
        },
      ),
    );
  }

  Widget _pill(String text, {Color? fg, Color? bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (bg ?? Colors.white.withOpacity(.06)),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border.withOpacity(.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg ?? Colors.white.withOpacity(.9),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _statButton(String n, String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Text(
              n,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(.65),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_err != null) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          backgroundColor: AppTheme.bg,
          elevation: 0,
          title: const Text('Perfil'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_err!, style: const TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

    final name =
        (_p['name'] ?? widget.fallbackName ?? 'Usuário').toString().trim();
    final bio = (_p['bio'] ?? '').toString().trim();
    final prof = (_p['profession'] ?? '').toString().trim();
    final city = (_p['city'] ?? '').toString().trim();
    final role = (_p['role'] ?? '').toString().trim();

    String avatar =
        (_p['avatar_url'] ?? widget.fallbackAvatar ?? '').toString().trim();
    if (avatar.isEmpty) avatar = AvatarCache.getLocalByUserId(widget.userId);

    final isPro = role == 'pro';
    final meId = (AuthService.user?.id ?? '').toString().trim();
    final isMe = meId.isNotEmpty && meId == widget.userId;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: Text(name.isEmpty ? 'Perfil' : name),
        actions: [
          IconButton(
            tooltip: 'Recarregar',
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh),
          )
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.gold,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(.65),
          labelStyle: const TextStyle(fontWeight: FontWeight.w900),
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Sobre'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border.withOpacity(.35)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: avatar.isEmpty ? null : () => _openAvatar(avatar),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white.withOpacity(.08),
                      backgroundImage:
                          avatar.isEmpty ? null : NetworkImage(avatar),
                      child: avatar.isEmpty
                          ? const Icon(Icons.person,
                              size: 32, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'Usuário' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _pill(
                              isPro ? 'PRO' : 'CLIENTE',
                              fg: AppTheme.gold,
                              bg: AppTheme.gold.withOpacity(.12),
                            ),
                            if (city.isNotEmpty) _pill(city),
                          ],
                        ),
                        if (prof.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            prof,
                            style: TextStyle(
                              color: Colors.white.withOpacity(.85),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isMe)
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _checkingFollow ? null : _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isFollowing ? AppTheme.card : AppTheme.gold,
                          foregroundColor:
                              _isFollowing ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: _isFollowing
                                  ? AppTheme.border.withOpacity(.35)
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                        child: _checkingFollow
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _isFollowing ? 'Seguindo' : 'Seguir',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border.withOpacity(.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statButton('$_posts', 'posts', () => _tab.animateTo(0)),
                  _statButton('$_followers', 'seguidores',
                      () => _openFollowList(followers: true)),
                  _statButton('$_following', 'seguindo',
                      () => _openFollowList(followers: false)),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // POSTS
                _postsGrid.isEmpty
                    ? Center(
                        child: Text(
                          'Sem posts ainda.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.8),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: _postsGrid.length,
                        itemBuilder: (_, i) {
                          final url = (_postsGrid[i]['media_url'] ?? '')
                              .toString()
                              .trim();
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: Colors.white.withOpacity(.06),
                              child: url.isEmpty
                                  ? const SizedBox.shrink()
                                  : Image.network(url, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),

                // SOBRE
                ListView(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: AppTheme.border.withOpacity(.35)),
                      ),
                      child: Text(
                        bio.isEmpty ? 'Sem bio ainda.' : bio,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.88),
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: AppTheme.border.withOpacity(.35)),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _pill(isPro ? 'Profissional' : 'Cliente'),
                          if (prof.isNotEmpty) _pill(prof),
                          if (city.isNotEmpty) _pill(city),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowListSheet extends StatefulWidget {
  final ScrollController controller;
  final String userId;
  final String title;
  final bool isFollowers; // true: seguidores | false: seguindo
  final void Function(String userId, String name, String avatar) openProfile;

  const _FollowListSheet({
    required this.controller,
    required this.userId,
    required this.title,
    required this.isFollowers,
    required this.openProfile,
  });

  @override
  State<_FollowListSheet> createState() => _FollowListSheetState();
}

class _FollowListSheetState extends State<_FollowListSheet> {
  final _sb = Supabase.instance.client;

  bool _loading = true;
  String? _err;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    AvatarCache.init();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });

    try {
      final targetCol = widget.isFollowers ? 'follower_id' : 'following_id';
      final filterCol = widget.isFollowers ? 'following_id' : 'follower_id';

      final rel = await _sb
          .from('user_follows')
          .select(targetCol)
          .eq(filterCol, widget.userId)
          .limit(2000)
          .timeout(const Duration(seconds: 12));

      final relList = (rel is List) ? rel : <dynamic>[];
      final ids = <String>[];

      for (final r in relList) {
        if (r is Map) {
          final v = (r[targetCol] ?? '').toString().trim();
          if (v.isNotEmpty) ids.add(v);
        }
      }

      if (ids.isEmpty) {
        _items = [];
        if (mounted) setState(() => _loading = false);
        return;
      }

      // busca perfis públicos
      final rows = await _sb
          .from('public_profiles')
          .select('id, name, avatar_url, role, city, profession')
          .inFilter('id', ids)
          .limit(2000)
          .timeout(const Duration(seconds: 12));

      _items = List<Map<String, dynamic>>.from(rows as List);

      // ordena na mesma ordem do ids
      final byId = <String, Map<String, dynamic>>{};
      for (final it in _items) {
        byId[(it['id'] ?? '').toString()] = it;
      }
      final sorted = <Map<String, dynamic>>[];
      for (final id in ids) {
        final it = byId[id];
        if (it != null) sorted.add(it);
      }
      _items = sorted;

      for (final it in _items) {
        final uid = (it['id'] ?? '').toString();
        final av = (it['avatar_url'] ?? '').toString().trim();
        if (uid.isNotEmpty && av.isNotEmpty)
          AvatarCache.rememberUserId(uid, av);
      }
    } catch (e) {
      _err = (e is TimeoutException)
          ? 'Timeout ao falar com o servidor (Supabase). Verifique sua internet/DNS e tente de novo.'
          : e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _pill(String text, {Color? fg, Color? bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (bg ?? Colors.white.withOpacity(.06)),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border.withOpacity(.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg ?? Colors.white.withOpacity(.9),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16),
                  ),
                ),
                IconButton(
                  tooltip: 'Recarregar',
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
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
                              'Nada por aqui ainda.',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.8),
                                  fontWeight: FontWeight.w800),
                            ),
                          )
                        : ListView.builder(
                            controller: widget.controller,
                            padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                            itemCount: _items.length,
                            itemBuilder: (_, i) {
                              final it = _items[i];
                              final uid = (it['id'] ?? '').toString();
                              final name = (it['name'] ?? 'Usuário').toString();
                              final avatar =
                                  (it['avatar_url'] ?? '').toString().trim();
                              final role = (it['role'] ?? '').toString().trim();
                              final city = (it['city'] ?? '').toString().trim();
                              final prof =
                                  (it['profession'] ?? '').toString().trim();
                              final isPro = role == 'pro';

                              return Card(
                                color: AppTheme.card,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Colors.white.withOpacity(.08),
                                    backgroundImage: avatar.isEmpty
                                        ? null
                                        : NetworkImage(avatar),
                                    child: avatar.isEmpty
                                        ? const Icon(Icons.person,
                                            color: Colors.white)
                                        : null,
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  subtitle: Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      _pill(isPro ? 'PRO' : 'CLIENTE',
                                          fg: AppTheme.gold,
                                          bg: AppTheme.gold.withOpacity(.12)),
                                      if (prof.isNotEmpty) _pill(prof),
                                      if (city.isNotEmpty) _pill(city),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    widget.openProfile(uid, name, avatar);
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
