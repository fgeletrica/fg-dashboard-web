import 'package:flutter/material.dart';
import '../services/local_store.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final _title = TextEditingController();
  final _date = TextEditingController();
  final _notes = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  Future<void> _load() async {
    _items = (await LocalStore.getAgenda()).cast<Map<String, dynamic>>();
    setState(() {});
  }

  Future<void> _add() async {
    final t = _title.text.trim();
    if (t.isEmpty) return;
    final item = {
      'title': t,
      'date': _date.text.trim(),
      'notes': _notes.text.trim(),
      'ts': DateTime.now().millisecondsSinceEpoch,
    };
    _items.insert(0, item);
    await LocalStore.setAgenda(_items);
    _title.clear();
    _date.clear();
    _notes.clear();
    setState(() {});
  }

  Future<void> _remove(int i) async {
    _items.removeAt(i);
    await LocalStore.setAgenda(_items);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _date.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration:
                  const InputDecoration(labelText: 'Título do compromisso'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _date,
              decoration: const InputDecoration(
                  labelText: 'Data / Hora (ex: 25/01 14:00)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              decoration:
                  const InputDecoration(labelText: 'Observações (opcional)'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _add,
                child: const Text('Salvar compromisso'),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('Sem compromissos ainda.'))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 10),
                      itemBuilder: (_, i) {
                        final it = _items[i];
                        return ListTile(
                          title: Text(it['title'] ?? ''),
                          subtitle: Text([
                            (it['date'] ?? '').toString(),
                            (it['notes'] ?? '').toString(),
                          ].where((x) => x.trim().isNotEmpty).join(' • ')),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _remove(i),
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
}
