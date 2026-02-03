import '../../utils/number_input.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/pro_access.dart';
import '../../services/materials_store.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // THEME
  final bg = AppTheme.bg;
  final card = AppTheme.card;
  final border = AppTheme.border;
  final gold = AppTheme.gold;

  // AUTH
  static const _kAdminPass = 'admin_pass_v1';
  static const _kAdminAuthed = 'admin_authed_v1';
  static const String _defaultPin = '2442';

  final _pinCtrl = TextEditingController();
  final _curPinCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();

  bool _loading = true;
  bool _authed = false;

  // CUPOM
  static const _kCupomEnabled = 'cupom_enabled_v1';
  static const _kCupomCode = 'cupom_code_v1';
  static const _kCupomPct = 'cupom_pct_v1';
  static const _kCupomEndAtMs = 'cupom_endat_ms_v1';

  bool _cupomEnabled = false;
  final _cupomCodeCtrl = TextEditingController();
  final _cupomPctCtrl = TextEditingController();
  final _cupomDaysCtrl = TextEditingController(text: '2');

  // HOME NOTICE
  static const _kHomeNotice = 'home_notice_v1';
  final _noticeCtrl = TextEditingController();

  // SERVIÇOS (tabela)
  static const _kServicePricesJson = 'service_prices_v1';
  final _svcNameCtrl = TextEditingController();
  final _svcPriceCtrl = TextEditingController();
  final _svcNotesCtrl = TextEditingController();
  List<Map<String, dynamic>> _servicePrices = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _curPinCtrl.dispose();
    _newPinCtrl.dispose();

    _cupomCodeCtrl.dispose();
    _cupomPctCtrl.dispose();
    _cupomDaysCtrl.dispose();

    _noticeCtrl.dispose();

    _svcNameCtrl.dispose();
    _svcPriceCtrl.dispose();
    _svcNotesCtrl.dispose();
    super.dispose();
  }

  // ---------------- helpers ----------------
  void _snack(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border.withOpacity(.45)),
        ),
      );

  double _toDouble(String s) =>
      double.tryParse(s.replaceAll(',', '.').trim()) ?? 0.0;

  Future<String> _getSavedPin() async {
    final sp = await SharedPreferences.getInstance();
    final saved = (sp.getString(_kAdminPass) ?? '').trim();
    return saved.isEmpty ? _defaultPin : saved;
  }

  // ---------------- load/save ----------------
  Future<void> _loadAll() async {
    final sp = await SharedPreferences.getInstance();

    final authed = sp.getBool(_kAdminAuthed) ?? false;

    _cupomEnabled = sp.getBool(_kCupomEnabled) ?? false;
    _cupomCodeCtrl.text = (sp.getString(_kCupomCode) ?? '').trim();
    _cupomPctCtrl.text = (sp.getString(_kCupomPct) ?? '').trim();

    final notice = (sp.getString(_kHomeNotice) ?? '').trim();
    _noticeCtrl.text = notice;

    // servicos
    final raw = (sp.getString(_kServicePricesJson) ?? '').trim();
    if (raw.isEmpty) {
      _servicePrices = [
        {"name": "Tomada 10A (un)", "price": 80.0, "notes": ""},
        {"name": "Tomada 20A (un)", "price": 95.0, "notes": ""},
        {"name": "Ponto de luz (un)", "price": 90.0, "notes": ""},
        {"name": "Chuveiro (instalacao)", "price": 150.0, "notes": ""},
        {"name": "Visita técnica", "price": 80.0, "notes": ""},
      ];
      await sp.setString(_kServicePricesJson, jsonEncode(_servicePrices));
    } else {
      try {
        final list = (jsonDecode(raw) as List).cast<dynamic>();
        _servicePrices =
            list.map((e) => (e as Map).cast<String, dynamic>()).toList();
      } catch (_) {
        _servicePrices = [];
      }
    }

    if (!mounted) return;
    setState(() {
      _authed = authed;
      _loading = false;
    });
  }

  Future<void> _saveCupom() async {
    final sp = await SharedPreferences.getInstance();

    final code = _cupomCodeCtrl.text.trim();
    final pct = _cupomPctCtrl.text.trim();
    final days = int.tryParse(_cupomDaysCtrl.text.trim()) ?? 0;

    if (_cupomEnabled && code.isEmpty) {
      _snack("Ativou cupom mas nao colocou o codigo.");
      return;
    }

    int? endAtMs;
    if (_cupomEnabled && days > 0) {
      endAtMs = DateTime.now().millisecondsSinceEpoch + (days * 86400000);
    } else if (!_cupomEnabled) {
      endAtMs = null;
    }

    await sp.setBool(_kCupomEnabled, _cupomEnabled);
    await sp.setString(_kCupomCode, code);
    await sp.setString(_kCupomPct, pct);

    if (endAtMs == null) {
      await sp.remove(_kCupomEndAtMs);
    } else {
      await sp.setInt(_kCupomEndAtMs, endAtMs);
    }

    _snack("Cupom salvo ✅");
  }

  Future<void> _expireCupomNow() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kCupomEnabled, false);
    await sp.setInt(
        _kCupomEndAtMs, DateTime.now().millisecondsSinceEpoch - 1000);
    _cupomEnabled = false;
    if (!mounted) return;
    setState(() {});
    _snack("Cupom expirado agora ✅");
  }

  Future<void> _saveNotice() async {
    final sp = await SharedPreferences.getInstance();
    final txt = _noticeCtrl.text.trim();
    await sp.setString(_kHomeNotice, txt);
    _snack("Aviso da Home salvo ✅");
  }

  Future<void> _saveServicePrices() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kServicePricesJson, jsonEncode(_servicePrices));
  }

  Future<void> _addServicePrice() async {
    final name = _svcNameCtrl.text.trim();
    final price = _toDouble(_svcPriceCtrl.text);
    final notes = _svcNotesCtrl.text.trim();

    if (name.isEmpty) {
      _snack("Nome do servico vazio.");
      return;
    }

    setState(() {
      _servicePrices.insert(0, {"name": name, "price": price, "notes": notes});
      _svcNameCtrl.clear();
      _svcPriceCtrl.clear();
      _svcNotesCtrl.clear();
    });
    await _saveServicePrices();
    _snack("Servico adicionado ✅");
  }

  Future<void> _removeServicePrice(int i) async {
    setState(() => _servicePrices.removeAt(i));
    await _saveServicePrices();
  }

  // ---------------- auth actions ----------------
  Future<void> _login() async {
    final typed = _pinCtrl.text.trim();
    final saved = await _getSavedPin();
    if (typed == saved) {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool(_kAdminAuthed, true);
      if (!mounted) return;
      setState(() => _authed = true);
      _pinCtrl.clear();
      return;
    }
    _snack("PIN incorreto");
  }

  Future<void> _logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kAdminAuthed, false);
    if (!mounted) return;
    setState(() => _authed = false);
  }

  Future<void> _changePin() async {
    final cur = _curPinCtrl.text.trim();
    final next = _newPinCtrl.text.trim();
    final saved = await _getSavedPin();

    if (cur != saved) {
      _snack("PIN atual incorreto");
      return;
    }
    if (next.length < 4) {
      _snack("Novo PIN precisa ter 4 digitos");
      return;
    }

    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kAdminPass, next);
    _curPinCtrl.clear();
    _newPinCtrl.clear();
    _snack("PIN atualizado ✅");
    if (!mounted) return;
    setState(() {});
  }

  // ---------------- PRO tools ----------------
  Future<_AdminStatus> _loadPro() async {
    final proDev = await ProAccess.getProDev();
    final until = await ProAccess.getTrialUntilMs();
    final left = (await ProAccess.trialRemaining());
    final has = await ProAccess.hasProAccessNow();
    return _AdminStatus(
      proDev: proDev,
      trialUntilMs: until,
      trialRemaining: left,
      hasAccessNow: has,
    );
  }

  String _fmtDate(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  Widget _cardBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_authed) return _buildLogin();
    return _buildAdmin();
  }

  Widget _buildLogin() {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(backgroundColor: bg, title: const Text('Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Catálogo de Materiais',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(
                  'Adiciona novos itens (cabos/disjuntores etc.) sem apagar seus materiais.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.sync),
                    label: const Text('Atualizar catálogo (seed)'),
                    onPressed: () async {
                      final added = await MaterialsStore.mergeSeed();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Catálogo atualizado ✅ +$added item(ns).')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _cardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acesso Admin',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _pinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: _dec(
                    'Digite o PIN',
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _login,
                    child: const Text('Entrar',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdmin() {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('Admin'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // CUPOM
          _cardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cupom / Promocao',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _cupomEnabled,
                  onChanged: (v) => setState(() => _cupomEnabled = v),
                  title: const Text('Ativar cupom',
                      style: TextStyle(color: Colors.white)),
                ),
                TextField(
                    controller: _cupomCodeCtrl,
                    decoration: _dec('Codigo (ex: FG10)')),
                const SizedBox(height: 10),
                TextField(
                  controller: _cupomDaysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Dias para expirar (ex: 2)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _cupomPctCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: _dec('Desconto (%)  -  ex: 10'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _saveCupom,
                    child: const Text('Salvar cupom',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _expireCupomNow,
                    child: const Text('Expirar agora',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // AVISO HOME
          _cardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Aviso na Home',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
                const SizedBox(height: 10),
                TextField(
                  controller: _noticeCtrl,
                  maxLines: 3,
                  decoration: _dec('Texto do aviso (vazio = nao mostra)'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _saveNotice,
                    child: const Text('Salvar aviso',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // SERVIÇOS
          _cardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tabela de servicos (PRO Wizard)',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
                const SizedBox(height: 10),
                TextField(
                    controller: _svcNameCtrl,
                    decoration: _dec('Nome do servico')),
                const SizedBox(height: 10),
                TextField(
                  controller: _svcPriceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: _dec('Preco (R\$)'),
                ),
                const SizedBox(height: 10),
                TextField(
                    controller: _svcNotesCtrl,
                    decoration: _dec('Obs (opcional)')),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _addServicePrice,
                    child: const Text('Adicionar servico',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 12),
                ..._servicePrices.asMap().entries.map((e) {
                  final i = e.key;
                  final it = e.value;
                  final name = (it['name'] ?? '').toString();
                  final price = (it['price'] is num)
                      ? (it['price'] as num).toDouble()
                      : 0.0;
                  final notes = (it['notes'] ?? '').toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border.withOpacity(.55)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              Text('R\$ ${price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.75),
                                      fontWeight: FontWeight.w700)),
                              if (notes.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(notes,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(.6))),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Excluir',
                          onPressed: () => _removeServicePrice(i),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // TROCAR PIN
          _cardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seguranca  -  trocar PIN',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
                const SizedBox(height: 10),
                TextField(
                  controller: _curPinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: _dec(
                    'PIN atual',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newPinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Novo PIN (4 digitos)'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _changePin,
                    child: const Text('Salvar novo PIN',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // PRO / TRIAL
          FutureBuilder<_AdminStatus>(
            future: _loadPro(),
            builder: (context, snap) {
              final s = snap.data;
              final loading = !snap.hasData;

              final proTxt = loading ? '...' : (s!.proDev ? 'SIM' : 'NÃO');
              final hasTxt =
                  loading ? '...' : (s!.hasAccessNow ? 'SIM' : 'NÃO');
              final untilTxt = loading
                  ? '...'
                  : (s!.trialUntilMs == null
                      ? ' - '
                      : _fmtDate(s.trialUntilMs!));
              final leftTxt =
                  loading ? '...' : ProAccess.formatDuration(s!.trialRemaining);

              return _cardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PRO / Trial (teste)',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('PRO (DEV): $proTxt',
                        style: TextStyle(color: Colors.white.withOpacity(.75))),
                    Text('Acesso agora: $hasTxt',
                        style: TextStyle(color: Colors.white.withOpacity(.75))),
                    const SizedBox(height: 6),
                    Text('TrialUntil: $untilTxt',
                        style: TextStyle(color: Colors.white.withOpacity(.75))),
                    Text('Restante: $leftTxt',
                        style: TextStyle(color: Colors.white.withOpacity(.75))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await ProAccess.setProDev(true);
                              _snack('PRO (DEV) ativado');
                              if (!mounted) return;
                              setState(() {});
                            },
                            child: const Text('Ativar PRO (DEV)'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await ProAccess.setProDev(false);
                              _snack('PRO (DEV) desativado');
                              if (!mounted) return;
                              setState(() {});
                            },
                            child: const Text('Desativar PRO (DEV)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await ProAccess.startTrial(
                                  duration: const Duration(minutes: 10));
                              _snack('Demo 10 min ativada ✅');
                              if (!mounted) return;
                              setState(() {});
                            },
                            child: const Text('Demo 10 min'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await ProAccess.startTrial(
                                  duration: const Duration(hours: 1));
                              _snack('Demo 1h ativada ✅');
                              if (!mounted) return;
                              setState(() {});
                            },
                            child: const Text('Demo 1 hora'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () async {
                          await ProAccess.resetTrial();
                          _snack('Trial resetado');
                          if (!mounted) return;
                          setState(() {});
                        },
                        child: const Text('Reset Trial'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.paywall),
                        child: const Text('Abrir Paywall'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminStatus {
  final bool proDev;
  final int? trialUntilMs;
  final Duration trialRemaining;
  final bool hasAccessNow;

  _AdminStatus({
    required this.proDev,
    required this.trialUntilMs,
    required this.trialRemaining,
    required this.hasAccessNow,
  });
}
