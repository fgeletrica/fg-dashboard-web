import '../services/pro_guard.dart';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'package:meu_ajudante_fg/routes/app_routes.dart';
import '../services/history_store.dart';
import '../models/budget_models.dart';
import 'budget_editor_screen.dart';
import 'tools_plus_screen.dart';

class CentroProScreen extends StatefulWidget {
  const CentroProScreen({super.key});

  @override
  State<CentroProScreen> createState() => _CentroProScreenState();
}

class _CentroProScreenState extends State<CentroProScreen> {
  bool _loading = true;
  bool _pro = false;

  List<Map<String, dynamic>> _recent = [];
  List<Map<String, dynamic>> _fav = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final pro = await ProGuard.hasPro();
    final recent = await HistoryStore.list();
    final fav = await HistoryStore.favItems();
    if (!mounted) return;
    setState(() {
      _pro = pro;
      _recent = recent;
      _fav = fav;
      _loading = false;
    });
  }

  Future<void> _clearHistory() async {
    await HistoryStore.clear();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Histórico limpo ✅')),
    );
  }

  Future<void> _openTemplate(String title) async {
    // cria um orçamento pronto (simples)
    final doc = BudgetDoc(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: '',
      createdAt: DateTime.now(),
      materials: [],
      services: [],
      marginPercent: true,
      marginValue: 15,
    );
    doc.clientName = '';
    doc.marginPercent = true;
    doc.marginValue = 15; // margem padrão
    doc.services.add(BudgetServiceLine(name: title, price: 0));

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BudgetEditorScreen(doc: doc)),
    );
    await _load();
  }

  Future<void> _openHistoryItem(Map<String, dynamic> it) async {
    // Se vier do orçamento, abre o editor com o doc id (sua store já deve lidar)
    // Aqui vamos só mostrar detalhes por enquanto (não quebra)
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text((it['title'] ?? 'Item').toString()),
        content: Text(it.toString()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar')),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: child,
    );
  }

  Widget _proPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppTheme.gold.withOpacity(.35)),
      ),
      child: Text('PRO',
          style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/logo.png',
                width: 26,
                height: 26,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.bolt, color: AppTheme.gold, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Centro PRO'),
          ],
        ),
        actions: [
          if (!_loading)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                  child: Text(_pro ? 'PRO' : 'FREE',
                      style: TextStyle(
                          color: _pro ? AppTheme.gold : Colors.white70,
                          fontWeight: FontWeight.w900))),
            )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tudo em um lugar: histórico, favoritos, modelos de orçamento, clientes e ferramentas.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(.85),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _proPill(),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // A) Histórico + Favoritos
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                              child: Text('Histórico & Favoritos',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16))),
                          TextButton(
                              onPressed: _clearHistory,
                              child: const Text('Limpar')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_fav.isNotEmpty) ...[
                        Text('Favoritos',
                            style: TextStyle(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        ..._fav.take(5).map((it) => _histTile(it)).toList(),
                        const SizedBox(height: 10),
                      ],
                      if (_recent.isEmpty)
                        Text('Sem histórico ainda.',
                            style:
                                TextStyle(color: Colors.white.withOpacity(.75)))
                      else ...[
                        Text('Recentes',
                            style: TextStyle(
                                color: Colors.white.withOpacity(.9),
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        ..._recent.take(6).map((it) => _histTile(it)).toList(),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // B) Modelos de orçamento
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Modelos de orçamento',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _tpl('Instalação residencial'),
                          _tpl('Manutenção / correção'),
                          _tpl('Padrão ENEL 127V'),
                          _tpl('Padrão ENEL 220V'),
                          _tpl('Circuito ar-condicionado'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // C) Clientes (linka pro que você já tem)
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Clientes',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.clientes),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.gold,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          icon: const Icon(Icons.people_alt),
                          label: const Text('Abrir Clientes',
                              style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // D) Ferramentas+
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ferramentas+',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ToolsPlusScreen())),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          icon: const Icon(Icons.handyman_outlined),
                          label: const Text('Abrir Ferramentas+',
                              style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Inclui: AWG⇄mm², W⇄A, tabela rápida, dicas de curva B/C/D.',
                          style:
                              TextStyle(color: Colors.white.withOpacity(.7))),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _histTile(Map<String, dynamic> it) {
    final id = (it['id'] ?? '').toString();
    final title = (it['title'] ?? 'Item').toString();
    final sub = (it['sub'] ?? '').toString();

    return InkWell(
      onTap: () => _openHistoryItem(it),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(Icons.history, color: Colors.white.withOpacity(.75)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900)),
                  if (sub.isNotEmpty)
                    Text(sub,
                        style: TextStyle(color: Colors.white.withOpacity(.65))),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await HistoryStore.toggleFav(id);
                await _load();
              },
              icon: Icon(Icons.star, color: AppTheme.gold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tpl(String name) {
    return OutlinedButton(
      onPressed: () => _openTemplate(name),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(.16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(name),
    );
  }
}
