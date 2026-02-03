import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../models/industrial_models.dart';
import '../services/industrial_store.dart';

class ChecklistsScreen extends StatefulWidget {
  const ChecklistsScreen({super.key});

  @override
  State<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends State<ChecklistsScreen> {
  final _shiftCtrl = ValueNotifier<String>('A');

  final List<_ChecklistTemplate> _templates = const [
    _ChecklistTemplate(
      id: 'loto_v1',
      title: 'LOTO / Segurança (Antes de mexer)',
      items: [
        'Bloqueio/etiquetagem aplicada (LOTO)',
        'E-Stop testado / intertravamentos conferidos',
        'Ausência de tensão confirmada (quando aplicável)',
        'Descarga de energia residual (pneumática/mecânica)',
        'Área isolada e sinalizada',
      ],
    ),
    _ChecklistTemplate(
      id: 'start_shift_v1',
      title: 'Início do turno (Ronda elétrica)',
      items: [
        'Quadros sem alarmes/cheiro de queimado',
        'Ventilação de painéis ok (filtros/ventoinhas)',
        'Cabos/esteiras sem sinais de atrito',
        'Sensores críticos limpos/alinhados',
        'Rede/IO sem falhas na HMI',
      ],
    ),
    _ChecklistTemplate(
      id: 'return_prod_v1',
      title: 'Retorno de produção (Após manutenção)',
      items: [
        'Parafusos/borneamentos conferidos',
        'Proteções resetadas e testadas',
        'Testes em vazio e em carga realizados',
        'Alarmes zerados e causa registrada',
        'Operação acompanhada (5 min) sem reincidência',
      ],
    ),
  ];

  Future<void> _runTemplate(_ChecklistTemplate t) async {
    final items = {for (final it in t.items) it: false};
    var shift = _shiftCtrl.value;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      builder: (_) => StatefulBuilder(
        builder: (context, setM) => Padding(
          padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Expanded(
                    child: Text(t.title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: shift,
                decoration: const InputDecoration(labelText: 'Turno'),
                items: const [
                  DropdownMenuItem(value: 'A', child: Text('Turno A')),
                  DropdownMenuItem(value: 'B', child: Text('Turno B')),
                  DropdownMenuItem(value: 'C', child: Text('Turno C')),
                  DropdownMenuItem(value: 'D', child: Text('Turno D')),
                ],
                onChanged: (v) => setM(() => shift = v ?? 'A'),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: items.keys.map((k) {
                    return CheckboxListTile(
                      value: items[k] ?? false,
                      title: Text(k,
                          style: TextStyle(
                              color: Colors.white.withOpacity(.85),
                              fontWeight: FontWeight.w700)),
                      onChanged: (v) => setM(() => items[k] = v ?? false),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final run = ChecklistRun(
                      checklistId: t.id,
                      checklistTitle: t.title,
                      shift: shift,
                      items: items,
                    );
                    await IndustrialStore.addChecklistRun(run);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Checklist salvo ✅')));
                  },
                  child: const Text('Salvar checklist'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
          backgroundColor: AppTheme.bg, title: const Text('Checklists & LOTO')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Templates',
              style: TextStyle(
                  color: Colors.white.withOpacity(.9),
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ..._templates.map((t) => _card(
                title: t.title,
                subtitle: '${t.items.length} itens',
                icon: Icons.checklist_outlined,
                onTap: () => _runTemplate(t),
              )),
          const SizedBox(height: 14),
          Text('Histórico',
              style: TextStyle(
                  color: Colors.white.withOpacity(.9),
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          FutureBuilder(
            future: IndustrialStore.listChecklistRuns(),
            builder: (context, snap) {
              final list = (snap.data as List<ChecklistRun>?) ?? const [];
              if (!snap.hasData)
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator()));
              if (list.isEmpty) {
                return Text('Sem histórico ainda.',
                    style: TextStyle(
                        color: Colors.white.withOpacity(.7),
                        fontWeight: FontWeight.w700));
              }
              return Column(
                children: list.take(12).map((r) {
                  final dt = DateTime.fromMillisecondsSinceEpoch(r.ts);
                  final done = r.items.values.where((v) => v).length;
                  return _card(
                    title: r.checklistTitle,
                    subtitle:
                        'Turno ${r.shift} • $done/${r.items.length} • ${dt.toString().substring(0, 16)}',
                    icon: Icons.history,
                    onTap: () {},
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _card(
      {required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border.withOpacity(.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.gold.withOpacity(.35)),
              ),
              child: Icon(icon, color: AppTheme.gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.white.withOpacity(.65),
                            fontWeight: FontWeight.w600)),
                  ]),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(.6)),
          ],
        ),
      ),
    );
  }
}

class _ChecklistTemplate {
  final String id;
  final String title;
  final List<String> items;
  const _ChecklistTemplate(
      {required this.id, required this.title, required this.items});
}
