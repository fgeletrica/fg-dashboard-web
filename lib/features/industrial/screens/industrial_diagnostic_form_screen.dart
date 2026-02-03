import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_theme.dart';
import '../models/industrial_diagnostic.dart';
import '../services/industrial_context.dart';
import '../services/industrial_catalog.dart';
import '../services/industrial_diagnostics_store.dart';

class IndustrialDiagnosticFormScreen extends StatefulWidget {
  const IndustrialDiagnosticFormScreen({super.key});

  @override
  State<IndustrialDiagnosticFormScreen> createState() =>
      _IndustrialDiagnosticFormScreenState();
}

class _IndustrialDiagnosticFormScreenState
    extends State<IndustrialDiagnosticFormScreen> {
  IndustrialContext? _ctx;
  bool _loading = true;

  String _line = 'Linha 2';
  String _shift = 'Manhã';

  String _group = '';
  String _machine = '';

  final _problem = TextEditingController();
  final _action = TextEditingController();
  final _root = TextEditingController();
  bool _hasRoot = false;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final c = await IndustrialContextService.loadMyContext();
    final now = DateTime.now();
    final shift = IndustrialCatalog.shiftAuto(now);

    // defaults de linha 2
    final groups = IndustrialCatalog.groupNamesForLine(_line);
    final g0 = groups.isEmpty ? 'GERAL' : groups.first;
    final items = IndustrialCatalog.itemsFor(_line, g0);
    final m0 = items.isEmpty ? '' : items.first;

    if (!mounted) return;
    setState(() {
      _ctx = c;
      _shift = shift;
      _group = g0;
      _machine = m0;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _problem.dispose();
    _action.dispose();
    _root.dispose();
    super.dispose();
  }

  void _onLineChanged(String v) {
    final groups = IndustrialCatalog.groupNamesForLine(v);
    final g0 = groups.isEmpty ? 'GERAL' : groups.first;
    final items = IndustrialCatalog.itemsFor(v, g0);
    final m0 = items.isEmpty ? '' : items.first;

    setState(() {
      _line = v;
      _group = g0;
      _machine = m0;
    });
  }

  void _onGroupChanged(String v) {
    final items = IndustrialCatalog.itemsFor(_line, v);
    final m0 = items.isEmpty ? '' : items.first;
    setState(() {
      _group = v;
      _machine = m0;
    });
  }

  String _finalMachine() {
    // Se tiver item selecionado, usa item. Se não, usa o grupo (ex: outras linhas)
    final it = _machine.trim();
    if (it.isNotEmpty) return it;
    return _group.trim();
  }

  Future<void> _save() async {
    if (_ctx == null) return;

    final u = Supabase.instance.client.auth.currentUser;
    if (u == null) return;

    final prob = _problem.text.trim();
    final act = _action.text.trim();

    if (prob.isEmpty || act.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha: Problema e Ação tomada.')),
      );
      return;
    }

    setState(() => _saving = true);

    final now = DateTime.now();
    final d = IndustrialDiagnostic(
      id: const Uuid().v4(),
      createdAtMs: now.millisecondsSinceEpoch,
      orgId: _ctx!.orgId,
      siteId: _ctx!.siteId,
      shift: _shift,
      line: _line,
      machineGroup: _group,
      machineItem: _finalMachine(),
      problem: prob,
      actionTaken: act,
      hasRootCause: _hasRoot,
      rootCause: _hasRoot ? _root.text.trim() : '',
      createdBy: u.id,
      createdByName: _ctx!.displayName,
    );

    try {
      await IndustrialDiagnosticsStore.insert(d);
      if (!mounted) return;
      setState(() => _saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diagnóstico fechado e salvo ✅')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar (RLS/role): $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = IndustrialCatalog.groupNamesForLine(_line);
    final items = IndustrialCatalog.itemsFor(_line, _group);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text('Novo Diagnóstico'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_ctx == null)
              ? Center(
                  child: Text(
                    'Sem role no DQX.\nRecarregue e confirme o auto-operator no SQL.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(.8)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _card([
                      _drop('Linha', _line, IndustrialCatalog.lines,
                          (v) => _onLineChanged(v)),
                      const SizedBox(height: 10),
                      _drop(
                          'Turno (auto)',
                          _shift,
                          const ['Manhã', 'Tarde', 'Noite'],
                          (v) => setState(() => _shift = v)),
                    ]),
                    const SizedBox(height: 12),
                    _card([
                      _drop('Máquina (grupo)', _group, groups,
                          (v) => _onGroupChanged(v)),
                      const SizedBox(height: 10),
                      if (items.isNotEmpty)
                        _drop('Máquina (item)', _machine,
                            ['(usar grupo)', ...items], (v) {
                          setState(() {
                            _machine = (v == '(usar grupo)') ? '' : v;
                          });
                        })
                      else
                        Text(
                          'Sem itens nesta linha/grupo.\nVai registrar a máquina como: "${_finalMachine()}".',
                          style: TextStyle(color: Colors.white.withOpacity(.7)),
                        ),
                    ]),
                    const SizedBox(height: 12),
                    _card([
                      _label('Problema'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _problem,
                        maxLines: 4,
                        decoration: _dec('Descreva o problema'),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _card([
                      _label('Ação tomada'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _action,
                        maxLines: 4,
                        decoration: _dec('O que foi feito para resolver'),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _card([
                      _label('Causa raiz'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Switch(
                            value: _hasRoot,
                            activeColor: AppTheme.gold,
                            onChanged: (v) => setState(() => _hasRoot = v),
                          ),
                          Text(_hasRoot ? 'SIM' : 'NÃO',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                      if (_hasRoot) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: _root,
                          maxLines: 2,
                          decoration: _dec('Descreva a causa raiz'),
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
                        onPressed: _saving ? null : _save,
                        child: Text(
                          _saving ? 'Salvando...' : 'Fechar diagnóstico',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
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

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppTheme.bg.withOpacity(.35),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
      );

  Widget _drop(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    final safeValue =
        items.contains(value) ? value : (items.isEmpty ? '' : items.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: safeValue.isEmpty ? null : safeValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.bg.withOpacity(.35),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (x) {
            final nv = (x ?? '').toString();
            if (nv.isNotEmpty) onChanged(nv);
          },
        ),
      ],
    );
  }
}
