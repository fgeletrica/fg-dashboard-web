import 'package:flutter/material.dart';
import '../services/local_store.dart';
import '../models/calc_to_budget.dart';

class BudgetsScreen extends StatefulWidget {
  final CalcToBudget? fromCalc;
  const BudgetsScreen({super.key, this.fromCalc});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final _client = TextEditingController();
  final _desc = TextEditingController();
  final _labor = TextEditingController(text: '0');
  final _material = TextEditingController(text: '0');
  final _margin = TextEditingController(text: '20');

  List<Map<String, dynamic>> _items = [];

  double _toD(String s) => double.tryParse(s.replaceAll(',', '.').trim()) ?? 0;

  double get subtotal => _toD(_labor.text) + _toD(_material.text);
  double get margem => subtotal * (_toD(_margin.text) / 100.0);
  double get total => subtotal + margem;

  Future<void> _load() async {
    _items = (await LocalStore.getBudgets()).cast<Map<String, dynamic>>();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _load();

    if (widget.fromCalc != null) {
      final c = widget.fromCalc!;
      _client.text = c.client;
      _desc.text =
          'Cálculo: ${c.powerW.toStringAsFixed(0)}W • ${c.voltage}V • Ib ${c.ib.toStringAsFixed(2)}A • '
          'Cabo ${c.cableMm2.toStringAsFixed(1)}mm² • DJ ${c.breakerA}A • Queda ${c.vdropPct.toStringAsFixed(2)}%';

      // sugestão base (você ajusta depois)
      _labor.text = '150';
      _material.text = '120';
      _margin.text = '20';
    }
  }

  @override
  void dispose() {
    _client.dispose();
    _desc.dispose();
    _labor.dispose();
    _material.dispose();
    _margin.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final c = _client.text.trim();
    if (c.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Informe o cliente.')));
      return;
    }

    final item = {
      'client': c,
      'desc': _desc.text.trim(),
      'labor': _labor.text.trim(),
      'material': _material.text.trim(),
      'margin': _margin.text.trim(),
      'total': total.toStringAsFixed(2),
      'ts': DateTime.now().millisecondsSinceEpoch,
    };

    _items.insert(0, item);
    await LocalStore.setBudgets(_items);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Orçamento salvo ✅')));
    setState(() {});
  }

  Future<void> _remove(int i) async {
    _items.removeAt(i);
    await LocalStore.setBudgets(_items);
    setState(() {});
  }

  Widget _row(String a, String b, {bool strong = false}) {
    final style = TextStyle(
        fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
        fontSize: strong ? 16 : 14);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(a, style: style)),
          Text(b, style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Orçamentos'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF131C2B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Novo orçamento',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                TextField(
                    controller: _client,
                    decoration: const InputDecoration(labelText: 'Cliente')),
                const SizedBox(height: 10),
                TextField(
                    controller: _desc,
                    decoration: const InputDecoration(labelText: 'Descrição')),
                const SizedBox(height: 10),
                TextField(
                    controller: _labor,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Mão de obra (R\$)')),
                const SizedBox(height: 10),
                TextField(
                    controller: _material,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Materiais (R\$)')),
                const SizedBox(height: 10),
                TextField(
                    controller: _margin,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Margem (%) (removido)')),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1420),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _row('Subtotal', 'R\$ ${subtotal.toStringAsFixed(2)}'),
                      _row('Margem', 'R\$ ${margem.toStringAsFixed(2)}'),
                      const Divider(),
                      _row('TOTAL', 'R\$ ${total.toStringAsFixed(2)}',
                          strong: true),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Atualizar total'))),
                const SizedBox(height: 10),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('Salvar orçamento'))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Histórico (offline)',
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (_items.isEmpty)
            const Text('Nenhum orçamento salvo ainda.',
                style: TextStyle(color: Colors.white60)),
          ..._items.asMap().entries.map((e) {
            final i = e.key;
            final it = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  color: const Color(0xFF131C2B),
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text((it['client'] ?? '').toString()),
                subtitle: Text((it['desc'] ?? '').toString(),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('R\$ ${(it['total'] ?? '0').toString()}'),
                    IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _remove(i)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
