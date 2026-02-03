import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../services/community/comments_service.dart';

class CommentsSheet extends StatefulWidget {
  final String postId;
  final String myName;
  final String myAvatar;

  const CommentsSheet({
    super.key,
    required this.postId,
    required this.myName,
    required this.myAvatar,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _ctrl = TextEditingController();
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await CommentsService.list(widget.postId);
    if (!mounted) return;
    setState(() {
      _items = r;
      _loading = false;
    });
  }

  Future<void> _send() async {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;

    await CommentsService.add(
      authorId: '',
      postId: widget.postId,
      content: txt,
      name: widget.myName,
      avatar: widget.myAvatar,
    );

    _ctrl.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .75,
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Comentários',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          const Divider(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final it = _items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: (it['user_avatar_url'] ?? '')
                                      .toString()
                                      .isEmpty
                                  ? null
                                  : NetworkImage(it['user_avatar_url']),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.white),
                                  children: [
                                    TextSpan(
                                      text: '${it['user_name']} ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900),
                                    ),
                                    TextSpan(text: it['body']),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Comentar...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(.5)),
                      filled: true,
                      fillColor: AppTheme.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.gold),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
