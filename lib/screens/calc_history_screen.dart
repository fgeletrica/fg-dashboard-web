import 'dart:convert';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/local_store.dart';
import 'package:meu_ajudante_fg/routes/app_routes.dart';

class CalcHistoryScreen extends StatefulWidget {
  const CalcHistoryScreen({super.key});

  @override
  State<CalcHistoryScreen> createState() => _CalcHistoryScreenState();
}

class _CalcHistoryScreenState extends State<CalcHistoryScreen> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final raw = await LocalStore.getCalcHistoryRaw();
    final list = <Map<String, dynamic>>[];
    for (final line in raw) {
      try {
        final j = jsonDecode(line);
        if (j is Map) list.add(j.cast<String, dynamic>());
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      items = list;
      loading = false;
    });
  }

  String _fmt(Map<String, dynamic> j, String k, String fallback) =>
      (j[k] ?? fallback).toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Histórico do cálculo'),
        actions: [
          if (!loading && items.isNotEmpty)
            IconButton(
              tooltip: 'Limpar',
              onPressed: () async {
                await LocalStore.clearCalcHistory();
                await _load();
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum cálculo salvo ainda.',
                    style: TextStyle(color: Colors.white.withOpacity(.70)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final j = items[i];
                    final title = _fmt(j, 'title', 'Cálculo');
                    final pot = _fmt(j, 'potW', '0');
                    final v = _fmt(j, 'tensaoV', '0');
                    final dist = _fmt(j, 'distM', '0');
                    final disj = _fmt(j, 'disjA', '-');
                    final cabo = _fmt(j, 'caboMm2', '-');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: AppTheme.border.withOpacity(.35)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history, color: AppTheme.gold),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900)),
                                const SizedBox(height: 6),
                                Text(
                                  'P: $pot W • V: $v • Dist: $dist m',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.70)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Disj: $disj A • Cabo: $cabo mm²',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.70)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.calc,
                                arguments: {
                                  'title': title,
                                  'powerW': j['potW'],
                                  'voltage': j['tensaoV'],
                                },
                              );
                            },
                            child: Text('Usar',
                                style: TextStyle(
                                    color: AppTheme.gold,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
