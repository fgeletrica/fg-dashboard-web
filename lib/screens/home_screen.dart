import 'package:flutter/material.dart';
import 'package:meu_ajudante_fg/routes/app_routes.dart';
import '../services/auth/auth_service.dart';
import '../core/app_theme.dart';
import 'services_market_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isPro = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getMyRole();
    if (!mounted) return;
    setState(() {
      _isPro = role == 'pro';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(_isPro ? 'Painel Profissional' : 'Painel Cliente'),
        backgroundColor: AppTheme.bg,
        elevation: 0,
      ),
      body: _isPro ? _proView() : _clientView(),
    );
  }

  Widget _clientView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _tile('Cálculo Elétrico', AppRoutes.calc),
        _tile('Materiais', AppRoutes.materiais),
        _tile('Marketplace de Serviços', AppRoutes.marketplace),
        _tile('Minha Conta', AppRoutes.conta),
      ],
    );
  }

  Widget _proView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _tile('Cálculo Elétrico', AppRoutes.calc),
        _tile('Ferramentas', AppRoutes.ferramentas),
        _tile('Orçamentos', AppRoutes.orcamentos),
        _tile('Agenda', AppRoutes.agenda),
        _tile('Marketplace (PRO)', AppRoutes.marketplace),
        _tile('Minha Conta', AppRoutes.conta),
      ],
    );
  }

  Widget _tile(String title, String route) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
