import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/profile_store.dart';

class ProfileSetupScreen extends StatefulWidget {
  final VoidCallback onDone;
  const ProfileSetupScreen({super.key, required this.onDone});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final nameCtrl = TextEditingController();
  final companyCtrl = TextEditingController(text: 'FG Elétrica');
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  bool accepted = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    companyCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      );

  Future<void> _save() async {
    final name = nameCtrl.text.trim();
    final company = companyCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha seu nome.')),
      );
      return;
    }
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aceite o termo para continuar.')),
      );
      return;
    }

    await ProfileStore.set(
      name: name,
      phone: phoneCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      company: company.isEmpty ? '—' : company,
    );

    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/logo.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.bolt, size: 64, color: AppTheme.gold),
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                'Bem-vindo 👋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Crie seu perfil (fica salvo no celular)',
                style: TextStyle(color: Colors.white.withOpacity(.7)),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
                controller: nameCtrl, decoration: _dec('Nome e sobrenome')),
            const SizedBox(height: 12),
            TextField(
                controller: companyCtrl,
                decoration: _dec('Empresa (opcional)')),
            const SizedBox(height: 12),
            TextField(
                controller: phoneCtrl, decoration: _dec('Telefone (opcional)')),
            const SizedBox(height: 12),
            TextField(
                controller: emailCtrl, decoration: _dec('E-mail (opcional)')),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(.12)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: accepted,
                    onChanged: (v) => setState(() => accepted = v ?? false),
                  ),
                  Expanded(
                    child: Text(
                      'Eu entendo que o app ajuda no cálculo, mas não substitui projeto/ART.',
                      style: TextStyle(color: Colors.white.withOpacity(.8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _save,
                child: const Text('Continuar',
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
