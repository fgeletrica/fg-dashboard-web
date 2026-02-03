import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'package:meu_ajudante_fg/routes/app_routes.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pagamento em breve 👀')),
    );
  }

  Widget _feature(String text, {bool pro = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          pro ? Icons.check_circle : Icons.check,
          color: pro ? AppTheme.gold : Colors.white.withOpacity(.7),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(.9),
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _planBox({
    required String title,
    required String price,
    required String subtitle,
    required bool highlight,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight ? AppTheme.gold : AppTheme.border.withOpacity(.35),
          width: highlight ? 2 : 1,
        ),
        boxShadow: highlight
            ? const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 20,
                  offset: Offset(0, 12),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: TextStyle(
              color: highlight ? AppTheme.gold : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(.75),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    highlight ? AppTheme.gold : Colors.white.withOpacity(.9),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onTap,
              child: Text(
                highlight ? 'Virar PRO agora' : 'Continuar FREE',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
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
        title: const Text('FG Elétrica PRO'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          Text(
            'Trabalhe como profissional.\nPasse mais confiança ao cliente.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'O FG Elétrica PRO desbloqueia recursos que fazem seu serviço parecer profissional de verdade.',
            style: TextStyle(
              color: Colors.white.withOpacity(.75),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          _feature('Gerar PDFs de orçamento SEM marca d’água', pro: true),
          const SizedBox(height: 8),
          _feature('PDFs ilimitados (FREE tem limite mensal)'),
          const SizedBox(height: 8),
          _feature('Relatórios técnicos profissionais'),
          const SizedBox(height: 8),
          _feature('Mais credibilidade na hora de fechar serviço'),
          const SizedBox(height: 8),
          _feature('Acesso total às ferramentas do app'),
          const SizedBox(height: 22),
          _planBox(
            title: 'Plano FREE',
            price: 'R\$ 0',
            subtitle: 'Para uso básico e testes',
            highlight: false,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 14),
          _planBox(
            title: 'Plano PRO',
            price: 'A partir de R\$ 1 / dia',
            subtitle: 'Sem limites • Sem marca d’água • Profissional',
            highlight: true,
            onTap: () => _soon(context),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Você pode continuar usando o FREE.\nO PRO é para quem quer fechar mais serviços.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
