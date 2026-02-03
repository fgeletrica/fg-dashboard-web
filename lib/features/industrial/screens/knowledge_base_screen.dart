import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../models/industrial_models.dart';
import '../services/industrial_store.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  final _q = TextEditingController();
  String _filter = '';
  List<KnowledgeItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _q.addListener(
        () => setState(() => _filter = _q.text.trim().toLowerCase()));
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await IndustrialStore.listKnowledge();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _addDialog() async {
    final t = TextEditingController();
    final tags = TextEditingController();
    final prob = TextEditingController();
    final fix = TextEditingController();
    final prev = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nova falha recorrente'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: t,
                  decoration: const InputDecoration(labelText: 'Título curto')),
              TextField(
                  controller: tags,
                  decoration: const InputDecoration(
                      labelText: 'Tags (ex: cola;palete;encoder)')),
              const SizedBox(height: 8),
              TextField(
                  controller: prob,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(labelText: 'Problema / sintoma')),
              TextField(
                  controller: fix,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(labelText: 'Correção / solução')),
              TextField(
                  controller: prev,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Prevenção')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              final item = KnowledgeItem(
                title: t.text.trim(),
                tags: tags.text.trim(),
                problem: prob.text.trim(),
                fix: fix.text.trim(),
                prevention: prev.text.trim(),
              );
              await IndustrialStore.addKnowledge(item);
              if (!context.mounted) return;
              Navigator.pop(context);
              await _load();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((e) {
      final hay = ('${e.title} ${e.tags} ${e.problem} ${e.fix} ${e.prevention}')
          .toLowerCase();
      return hay.contains(_filter);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Falhas recorrentes'),
        actions: [
          IconButton(onPressed: _addDialog, icon: const Icon(Icons.add)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _q,
              decoration: InputDecoration(
                hintText: 'Buscar (ex: cola, palete, sensor, encoder...)',
                filled: true,
                fillColor: AppTheme.card,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(.12))),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final k = filtered[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: AppTheme.border.withOpacity(.35)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                        k.title.isEmpty
                                            ? 'Sem título'
                                            : k.title,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () async {
                                      await IndustrialStore.deleteKnowledge(
                                          k.id);
                                      await _load();
                                    },
                                  ),
                                ],
                              ),
                              if (k.tags.trim().isNotEmpty)
                                Text('Tags: ${k.tags}',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(.75),
                                        fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              _sec('Problema', k.problem),
                              _sec('Solução', k.fix),
                              _sec('Prevenção', k.prevention),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sec(String title, String body) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: Colors.white.withOpacity(.85),
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(body,
            style: TextStyle(
                color: Colors.white.withOpacity(.75),
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
