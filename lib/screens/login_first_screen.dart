import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';

class LoginFirstScreen extends StatefulWidget {
  const LoginFirstScreen({super.key});

  @override
  State<LoginFirstScreen> createState() => _LoginFirstScreenState();
}

class _LoginFirstScreenState extends State<LoginFirstScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool hide = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    if (emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha.')),
      );
      return;
    }
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('first_login_done_v1', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Image.asset('assets/logo.png', height: 120, fit: BoxFit.contain),
              const SizedBox(height: 10),
              const Text(
                'FG Elétrica',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 26),
              ),
              const SizedBox(height: 6),
              Text(
                'Por favor, preencha os campos abaixo',
                style: TextStyle(color: Colors.white.withOpacity(.75)),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: emailCtrl,
                decoration: _dec('Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: hide,
                decoration: _dec('Senha').copyWith(
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => hide = !hide),
                    icon: Icon(hide ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.gold),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _enter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.card,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Realizar Login',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _enter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.card,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Criar uma Conta',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final sp = await SharedPreferences.getInstance();
                    await sp.setBool('first_login_done_v1', true);
                    if (!mounted) return;
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.card,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Preciso de Ajuda',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppTheme.card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppTheme.gold.withOpacity(.7))),
    );
  }
}
