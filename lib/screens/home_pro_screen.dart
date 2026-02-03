import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_theme.dart';
import 'package:meu_ajudante_fg/routes/app_routes.dart';
import '../services/app_mode_store.dart';
import '../widgets/pro_trial_countdown.dart';
import 'about_screen.dart';
import 'mode_select_screen.dart';

class HomeProScreen extends StatefulWidget {
  const HomeProScreen({super.key});

  @override
  State<HomeProScreen> createState() => _HomeProScreenState();
}

class _HomeProScreenState extends State<HomeProScreen> {
  Timer? _adminHold;
  Timer? _ticker;

  bool _cupomEnabled = false;
  String _cupomCode = '';
  String _cupomPct = '';
  int? _cupomEndAtMs;

  @override
  void initState() {
    super.initState();
    _loadCupom();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_cupomEndAtMs == null) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _adminHold?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  void _go(String route) => Navigator.of(context).pushNamed(route);

  Future<void> _openModeSelect() async {
    await AppModeStore.clear();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ModeSelectScreen()),
    );
  }

  Future<void> _loadCupom() async {
    final sp = await SharedPreferences.getInstance();
    final enabled = sp.getBool('cupom_enabled_v1') ?? false;
    final code = (sp.getString('cupom_code_v1') ?? '').trim();
    final pct = (sp.getString('cupom_pct_v1') ?? '').trim();
    final endAtMs = sp.getInt('cupom_endat_ms_v1');

    // auto-desativa se expirou
    if (endAtMs != null && DateTime.now().millisecondsSinceEpoch > endAtMs) {
      await sp.setBool('cupom_enabled_v1', false);
    }

    if (!mounted) return;
    setState(() {
      _cupomEnabled = enabled ||
          (endAtMs != null && DateTime.now().millisecondsSinceEpoch < endAtMs);
      _cupomCode = code;
      _cupomPct = pct;
      _cupomEndAtMs = endAtMs;
    });
  }

  String _fmtLeft(int msLeft) {
    if (msLeft <= 0) return 'expirado';
    final s = (msLeft / 1000).floor();
    final d = s ~/ 86400;
    final h = (s % 86400) ~/ 3600;
    final m = (s % 3600) ~/ 60;
    return '${d}d ${h}h ${m}m';
  }

  Widget _pill(String text, {Color? bg, Color? fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg ?? Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppTheme.border.withOpacity(.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg ?? Colors.white.withOpacity(.9),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _proCard() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hasCupom = _cupomEnabled && _cupomCode.isNotEmpty;
    final left = (_cupomEndAtMs == null) ? null : (_cupomEndAtMs! - now);
    final showTimer = hasCupom && left != null && left > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCupom ? 'Cupom ativo:' : 'Teste grátis PRO termina em:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DefaultTextStyle(
                  style: TextStyle(
                    color: AppTheme.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  child: hasCupom
                      ? Text(
                          showTimer
                              ? '${_cupomCode} (${_cupomPct.isEmpty ? '0' : _cupomPct}%) — expira em ${_fmtLeft(left!)}'
                              : '${_cupomCode} (${_cupomPct.isEmpty ? '0' : _cupomPct}%)',
                        )
                      : const ProTrialCountdown(),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill('Plano Mensal'),
                    _pill(
                      'Oferta Anual',
                      bg: AppTheme.gold.withOpacity(.12),
                      fg: AppTheme.gold,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onPressed: () => _go(AppRoutes.paywall),
            child: const Text('Ver PRO',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _gridCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    bool proTag = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border.withOpacity(.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border.withOpacity(.25)),
                  ),
                  child: Icon(icon, color: AppTheme.gold),
                ),
                const Spacer(),
                if (proTag)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(.14),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppTheme.gold.withOpacity(.35)),
                    ),
                    child: Text(
                      'PRO',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                height: 1.10,
              ),
            ),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withOpacity(.70),
                    fontWeight: FontWeight.w700,
                    height: 1.15)),
            const Spacer(),
            Row(
              children: [
                Text('Abrir',
                    style: TextStyle(
                        color: Colors.white.withOpacity(.65),
                        fontWeight: FontWeight.w800)),
                const Spacer(),
                Icon(Icons.chevron_right, color: Colors.white.withOpacity(.55)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: GestureDetector(
          onTapDown: (_) {
            _adminHold?.cancel();
            _adminHold = Timer(const Duration(seconds: 5), () {
              if (!mounted) return;
              Navigator.of(context).pushNamed(AppRoutes.admin);
            });
          },
          onTapUp: (_) => _adminHold?.cancel(),
          onTapCancel: () => _adminHold?.cancel(),
          child: const Text('Painel Profissional'),
        ),
        actions: [
          IconButton(
            tooltip: 'Trocar modo',
            icon: const Icon(Icons.swap_horiz),
            onPressed: _openModeSelect,
          ),
          IconButton(
            tooltip: 'Tutoriais',
            icon: const Icon(Icons.help_outline),
            onPressed: () => _go(AppRoutes.tutoriais),
          ),
          IconButton(
            tooltip: 'Sobre',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
          IconButton(
            tooltip: 'Minha Conta',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => _go(AppRoutes.conta),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
        children: [
          _proCard(),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _gridCard(context,
                  icon: Icons.calculate_outlined,
                  title: 'Cálculo\nElétrico',
                  subtitle: 'Cabo, disjuntor, queda',
                  route: AppRoutes.calc),
              _gridCard(context,
                  icon: Icons.handyman_outlined,
                  title: 'Ferramentas',
                  subtitle: 'Utilitários do app',
                  route: AppRoutes.ferramentas),
              _gridCard(context,
                  icon: Icons.ac_unit,
                  title: 'Equipamentos',
                  subtitle: 'Tabela e sugestões',
                  route: AppRoutes.equipamentos,
                  proTag: true),
              _gridCard(context,
                  icon: Icons.receipt_long_outlined,
                  title: 'Orçamentos',
                  subtitle: 'Criar e editar',
                  route: AppRoutes.orcamentos),
              _gridCard(context,
                  icon: Icons.event_note_outlined,
                  title: 'Agenda',
                  subtitle: 'Compromissos',
                  route: AppRoutes.agenda),
              _gridCard(context,
                  icon: Icons.miscellaneous_services_outlined,
                  title: 'Marketplace\nServiços',
                  subtitle: 'Ver pedidos e chamar',
                  route: AppRoutes.marketplace),
            ],
          ),
        ],
      ),
    );
  }
}
