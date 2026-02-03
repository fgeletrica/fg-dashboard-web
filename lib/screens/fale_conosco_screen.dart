import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';

class FaleConoscoScreen extends StatelessWidget {
  const FaleConoscoScreen({super.key});

  // WhatsApp: 55 + DDD + número
  static const _phone = '5521997901083';

  Future<void> _openWhatsApp(BuildContext context, String msg) async {
    final uri =
        Uri.parse('https://wa.me/$_phone?text=${Uri.encodeComponent(msg)}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Fale Conosco'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _btn(
                context,
                icon: Icons.report_gmailerrorred_outlined,
                title: 'Reportar Erro',
                onTap: () => _openWhatsApp(
                  context,
                  'Olá! Encontrei um erro no app FG Elétrica:\n\n(Descreva aqui)\n\nModelo do celular:\nVersão do app:',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _btn(
                context,
                icon: Icons.chat_bubble_outline,
                title: 'Dúvida/Sugestão',
                onTap: () => _openWhatsApp(
                  context,
                  'Olá! Tenho uma dúvida/sugestão no app FG Elétrica:\n\n(Escreva aqui)',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
