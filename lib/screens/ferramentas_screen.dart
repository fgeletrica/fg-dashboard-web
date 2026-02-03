import 'package:flutter/material.dart';
import 'materials_screen.dart';
import 'paywall_screen.dart';
import '../core/app_theme.dart';
import '../routes/app_routes.dart';
import 'centro_pro_screen.dart';
import '../services/pro_access.dart';
import 'signature_screen.dart';
import 'services_pro_screen.dart';
import '../features/diagnostico/diagnostico_screen.dart';

class FerramentasScreen extends StatelessWidget {
  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _safePush(BuildContext context, Widget page) async {
    try {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    } catch (e) {
      _snack(context, 'Não consegui abrir essa tela agora.');
    }
  }

  Future<void> _open(BuildContext context,
      {required bool proOnly, required Widget page}) async {
    final hasPro = await ProAccess.hasProAccessNow();
    if (proOnly && !hasPro) {
      await _safePush(context, const PaywallScreen());
      return;
    }
    await _safePush(context, page);
  }

  const FerramentasScreen({super.key});

  Future<void> _go(BuildContext context, String route) async {
    try {
      await Navigator.of(context).pushNamed(route);
    } catch (_) {
      _snack(context, 'Tela não cadastrada (rota).');
    }
  }

  Future<void> _openPro(BuildContext context, Widget screen) async {
    final has = await ProAccess.hasProAccessNow();
    if (!has) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Recurso PRO — desbloqueie para usar ✅")),
        );
        await _safePush(context, const PaywallScreen());
      }
      return;
    }
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text("Ferramentas"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: Icon(Icons.rule_folder),
                  title: Text('Diagnóstico guiado'),
                  subtitle: Text('Perguntas rápidas → hipótese + checklist'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const DiagnosticoScreen()),
                    );
                  },
                ),
              ),
              _tile(context, Icons.construction, "Meus\nMateriais", () {
                // PRO: por enquanto abre a tela de materiais existente se sua rota existir
                // Se sua rota for outra, me fala que eu ajusto.
                _open(context, proOnly: false, page: const MaterialsScreen());
              }, proTag: true, proOnly: false),
              _tile(context, Icons.engineering, "Meus Serviços", () {
                _openPro(context, const ServicesProScreen());
              }, proTag: true, proOnly: true),
              _tile(context, Icons.people_alt, "Meus Clientes",
                  () => _go(context, AppRoutes.clientes),
                  proTag: false),
              _tile(context, Icons.draw, "Assinatura\nDigital", () {
                _openPro(context, const SignatureScreen());
              }, proTag: true, proOnly: true),
              _tile(context, Icons.calculate, "Conversão\nde unidades",
                  () => _go(context, AppRoutes.unitConvert),
                  proTag: false),
              _tile(context, Icons.table_chart, "Tabela de cabos",
                  () => _go(context, AppRoutes.cabosTabela),
                  proTag: false),
              _tile(context, Icons.bolt, "Queda de tensão",
                  () => _go(context, AppRoutes.quedaTensao),
                  proTag: false),
              _tile(context, Icons.stars, 'Centro\nPRO', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CentroProScreen()));
              }, proTag: true, proOnly: false),
              _tileWide(
                  context,
                  Icons.directions_car,
                  "Cálculo de\nDeslocamento",
                  () => _go(context, AppRoutes.deslocamento)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool proTag = false,
    bool proOnly = false,
  }) {
    return InkWell(
      onTap: () async {
        if (proOnly) {
          final has = await ProAccess.hasProAccessNow();
          if (!has) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Recurso PRO — desbloqueie para usar ✅")),
              );
              await _safePush(context, const PaywallScreen());
            }
            return;
          }
        }
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: (MediaQuery.of(context).size.width - 16 * 2 - 14) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border.withOpacity(.35)),
          boxShadow: const [
            BoxShadow(
                blurRadius: 14, offset: Offset(0, 8), color: Color(0x22000000)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.gold),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            if (proTag) ...[
              const SizedBox(height: 10),
              Text("PRO",
                  style: TextStyle(
                      color: AppTheme.gold, fontWeight: FontWeight.w900)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tileWide(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border.withOpacity(.35)),
          boxShadow: const [
            BoxShadow(
                blurRadius: 14, offset: Offset(0, 8), color: Color(0x22000000)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.gold),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16))),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(.55)),
          ],
        ),
      ),
    );
  }
}
