import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_theme.dart';
import '../models/industrial_diagnostic.dart';
import '../services/industrial_context.dart';
import '../services/industrial_catalog.dart';
import '../services/industrial_diagnostics_store.dart';

class NewDiagnosticScreen extends StatefulWidget {
  const NewDiagnosticScreen({super.key});

  @override
  State<NewDiagnosticScreen> createState() => _NewDiagnosticScreenState();
}

class _NewDiagnosticScreenState extends State<NewDiagnosticScreen> {
  IndustrialContext? ctx;
  bool loading = true;

  String line = 'Linha 2';
  String group = '';
  String item = '';

  final problemCtrl = TextEditingController();
  final actionCtrl = TextEditingController();

  bool hasRoot = false;
  final rootCtrl = TextEditingController();

  bool saving = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final c = await IndustrialContextService.loadMyContext();

    final groups = IndustrialCatalog.groupNames(line);
    final g0 = groups.isEmpty ? '' : groups.first;
    final items =
        (g0.isEmpty) ? <String>[] : IndustrialCatalog.itemsFor(line, g0);
    final i0 = items.isEmpty ? '' : items.first;

    if (!mounted) return;
    setState(() {
      ctx = c;
      group = g0;
      item = i0;
      loading = false;
    });
  }

  @override
  void dispose() {
    problemCtrl.dispose();
    actionCtrl.dispose();
    rootCtrl.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final c = ctx;
    if (c == null) return;

    final u = Supabase.instance.client.auth.currentUser;
    if (u == null) return;

    final prob = problemCtrl.text.trim();
    final act = actionCtrl.text.trim();

    if (line.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecione a linha.')));
      return;
    }
    if (group.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione a máquina (grupo).')));
      return;
    }
    if (prob.isEmpty || act.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha Problema e Ação tomada.')));
      return;
    }

    setState(() => saving = true);

    final now = DateTime.now();
    final shift = IndustrialContextService.shiftNow(now);

    final d = IndustrialDiagnostic(
      id: const Uuid().v4(),
      createdAtMs: now.millisecondsSinceEpoch,
      orgId: c.orgId,
      siteId: c.siteId,
      shift: shift,
      line: line,
      machineGroup: group,
      machineItem: item,
      problem: prob,
      actionTaken: act,
      hasRootCause: hasRoot,
      rootCause: hasRoot ? rootCtrl.text.trim() : '',
      createdBy: u.id,
      createdByName: c.displayName,
    );

    try {
      await IndustrialDiagnosticsStore.insert(d);
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Diagnóstico salvo ✅')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = IndustrialCatalog.groupNames(line);
    final items =
        (group.isEmpty) ? <String>[] : IndustrialCatalog.itemsFor(line, group);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
          backgroundColor: AppTheme.bg,
          elevation: 0,
          title: const Text('Novo Diagnóstico')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (ctx == null)
              ? Center(
                  child: Text(
                    'Sem role no DQX.\nSe o SQL auto-operator estiver ok,\naguarde alguns segundos e recarregue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(.8)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _card([
                      _label('Linha'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: line,
                        decoration: _dec(),
                        items: IndustrialCatalog.lines
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          final nl = (v ?? line).toString();
                          final g = IndustrialCatalog.groupNames(nl);
                          final g0 = g.isEmpty ? '' : g.first;
                          final it = g0.isEmpty
                              ? <String>[]
                              : IndustrialCatalog.itemsFor(nl, g0);
                          final i0 = it.isEmpty ? '' : it.first;
                          setState(() {
                            line = nl;
                            group = g0;
                            item = i0;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _label('Máquina (grupo)'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: groups.contains(group)
                            ? group
                            : (groups.isEmpty ? null : groups.first),
                        decoration: _dec(),
                        items: groups
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          final ng = (v ?? '').toString();
                          final it = ng.isEmpty
                              ? <String>[]
                              : IndustrialCatalog.itemsFor(line, ng);
                          final i0 = it.isEmpty ? '' : it.first;
                          setState(() {
                            group = ng;
                            item = i0;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _label('Máquina (item)'),
                      const SizedBox(height: 8),
                      if (items.isEmpty)
                        Text(
                          'Sem itens cadastrados. Vai salvar como: "$group".',
                          style: TextStyle(color: Colors.white.withOpacity(.7)),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: items.contains(item) ? item : items.first,
                          decoration: _dec(),
                          items: items
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => item = (v ?? item).toString()),
                        ),
                    ]),
                    const SizedBox(height: 12),
                    _card([
                      _label('Problema'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: problemCtrl,
                        maxLines: 4,
                        decoration: _dec(
                            hint:
                                'Descreva o problema (texto livre por enquanto)'),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _card([
                      _label('Ação tomada'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: actionCtrl,
                        maxLines: 4,
                        decoration: _dec(
                            hint:
                                'O que foi feito para resolver (texto livre por enquanto)'),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _card([
                      _label('Causa raiz'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Switch(
                            value: hasRoot,
                            activeColor: AppTheme.gold,
                            onChanged: (v) => setState(() => hasRoot = v),
                          ),
                          Text(hasRoot ? 'SIM' : 'NÃO',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                      if (hasRoot) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: rootCtrl,
                          maxLines: 2,
                          decoration: _dec(hint: 'Descreva a causa raiz'),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: saving ? null : save,
                        child: Text(
                            saving ? 'Salvando...' : 'Fechar diagnóstico',
                            style:
                                const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _card(List<Widget> kids) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: kids),
    );
  }

  Widget _label(String t) =>
      Text(t, style: const TextStyle(fontWeight: FontWeight.w900));

  InputDecoration _dec({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppTheme.bg.withOpacity(.35),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
      );
}
