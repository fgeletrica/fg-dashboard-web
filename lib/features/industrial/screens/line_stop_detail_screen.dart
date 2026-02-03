import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:meu_ajudante_fg/core/app_theme.dart';
import 'package:meu_ajudante_fg/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _industrial = true;

  final _email = TextEditingController();
  final _matricula = TextEditingController();
  final _pass = TextEditingController();

  bool _busy = false;
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _matricula.dispose();
    _pass.dispose();
    super.dispose();
  }

  String _digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');
  String _industrialEmail(String mat) => '${_digits(mat)}@fg.com';

  InputDecoration _dec({
    required String label,
    String? hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppTheme.bg.withOpacity(.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _segment() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.bg.withOpacity(.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _industrial = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _industrial
                      ? AppTheme.gold.withOpacity(.95)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Industrial',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _industrial
                          ? Colors.black
                          : Colors.white.withOpacity(.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _industrial = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_industrial
                      ? AppTheme.gold.withOpacity(.95)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Residencial/Predial',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: !_industrial
                          ? Colors.black
                          : Colors.white.withOpacity(.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_busy) return;

    final pass = _pass.text;
    if (pass.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha muito curta (mínimo 6).')),
      );
      return;
    }

    String emailToUse;

    if (_industrial) {
      final m = _digits(_matricula.text);
      if (m.length != 7) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Matrícula inválida. Use 7 números (ex: 6131450).')),
        );
        return;
      }
      emailToUse = _industrialEmail(m);
    } else {
      final e = _email.text.trim().toLowerCase();
      if (!e.contains('@') || !e.contains('.')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email inválido.')),
        );
        return;
      }
      emailToUse = e;
    }

    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailToUse,
        password: pass,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.gate);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no login: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border.withOpacity(.35)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                // se sua tela tinha logo, mantém o visual simples e limpo
                Text(
                  'FG Elétrica',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.95),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Entre para acessar seu painel',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.75),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 14),
                _segment(),
                const SizedBox(height: 14),

                if (_industrial) ...[
                  TextField(
                    controller: _matricula,
                    decoration: _dec(
                      label: 'Matrícula',
                      hint: 'Ex: 6131450',
                      icon: Icons.badge,
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ] else ...[
                  TextField(
                    controller: _email,
                    decoration: _dec(
                      label: 'Email',
                      hint: 'seuemail@exemplo.com',
                      icon: Icons.email,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                ],

                const SizedBox(height: 10),

                TextField(
                  controller: _pass,
                  decoration: _dec(
                    label: 'Senha',
                    icon: Icons.lock,
                    suffix: IconButton(
                      onPressed: () => setState(() => _hide = !_hide),
                      icon:
                          Icon(_hide ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  obscureText: _hide,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                ),

                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _busy ? null : _login,
                    child: Text(
                      _busy ? 'Entrando...' : 'Entrar',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.register),
                  child: const Text('Criar conta'),
                ),

                const SizedBox(height: 6),
                Text(
                  _industrial
                      ? 'Industrial: login é matrícula + senha.'
                      : 'Residencial: login é email + senha.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(.6), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ao continuar, você concorda em usar o app de forma responsável.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(.45), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
