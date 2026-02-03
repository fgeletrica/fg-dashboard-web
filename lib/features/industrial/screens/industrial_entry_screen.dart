import "dart:async";
import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "package:meu_ajudante_fg/core/app_theme.dart";
import "industrial_home_screen.dart";

class IndustrialEntryScreen extends StatefulWidget {
  const IndustrialEntryScreen({super.key});

  @override
  State<IndustrialEntryScreen> createState() => _IndustrialEntryScreenState();
}

class _IndustrialEntryScreenState extends State<IndustrialEntryScreen> {
  StreamSubscription<AuthState>? _sub;
  Session? get _session => Supabase.instance.client.auth.currentSession;

  bool _isRegister = false;
  bool _busy = false;

  final _nameCtrl = TextEditingController();
  final _matCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  String? _error;

  @override
  void initState() {
    super.initState();
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _nameCtrl.dispose();
    _matCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  String _onlyDigits(String s) => s.replaceAll(RegExp(r"[^0-9]"), "");

  String? _validateMatricula(String raw) {
    final m = _onlyDigits(raw);
    if (m.isEmpty) return "Informe a matrícula";
    if (m.length != 7) return "Matrícula deve ter 7 números";
    return null;
  }

  String _emailFromMatricula(String raw) {
    final m = _onlyDigits(raw);
    return "$m@industrial.fg"; // email interno pro Supabase Auth
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (_isRegister) {
      final nm = _nameCtrl.text.trim();
      if (nm.isEmpty) {
        setState(() => _error = "Informe seu nome");
        return;
      }
      if (nm.length < 2) {
        setState(() => _error = "Nome muito curto");
        return;
      }
    }

    final matErr = _validateMatricula(_matCtrl.text);
    if (matErr != null) {
      setState(() => _error = matErr);
      return;
    }

    final pass = _passCtrl.text;
    if (pass.trim().length < 6) {
      setState(() => _error = "Senha deve ter pelo menos 6 caracteres");
      return;
    }

    if (_isRegister) {
      if (_pass2Ctrl.text != pass) {
        setState(() => _error = "As senhas não conferem");
        return;
      }
    }

    final matricula = _onlyDigits(_matCtrl.text);
    final email = _emailFromMatricula(matricula);

    setState(() => _busy = true);
    try {
      final auth = Supabase.instance.client.auth;

      if (_isRegister) {
        final name = _nameCtrl.text.trim();

        await auth.signUp(
          email: email,
          password: pass,
          data: {
            // ✅ o trigger vai ler isso e montar "Nome (Matricula)"
            "display_name": name,
            "matricula": matricula,
          },
        );
      } else {
        await auth.signInWithPassword(email: email, password: pass);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_session != null) return const IndustrialHomeScreen();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text("Industrial"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border.withOpacity(.35)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isRegister
                      ? "Criar conta (Industrial)"
                      : "Entrar (Industrial)",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.95),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegister
                      ? "Cadastre nome + matrícula (7 dígitos) e senha."
                      : "Acesso por matrícula (7 dígitos) e senha.",
                  style: TextStyle(color: Colors.white.withOpacity(.75)),
                ),
                const SizedBox(height: 14),
                if (_isRegister) ...[
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Nome",
                      hintText: "Ex: Felype Santos",
                      filled: true,
                      fillColor: AppTheme.bg.withOpacity(.25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: _matCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Matrícula",
                    hintText: "Ex: 6131450",
                    filled: true,
                    fillColor: AppTheme.bg.withOpacity(.25),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Senha",
                    filled: true,
                    fillColor: AppTheme.bg.withOpacity(.25),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_isRegister) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pass2Ctrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirmar senha",
                      filled: true,
                      fillColor: AppTheme.bg.withOpacity(.25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
                if ((_error ?? "").trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.redAccent.withOpacity(.95),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
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
                    onPressed: _busy ? null : _submit,
                    child: Text(
                      _busy
                          ? "Aguarde..."
                          : (_isRegister ? "Criar conta" : "Entrar"),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () {
                                setState(() {
                                  _isRegister = !_isRegister;
                                  _error = null;
                                });
                              },
                        child: Text(
                            _isRegister ? "Já tenho conta" : "Criar conta"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegister
                      ? "Depois de criar, aguarde alguns segundos e faça login."
                      : "Se criar conta agora e der \"sem role\", aguarde e clique em Recarregar.",
                  style: TextStyle(
                      color: Colors.white.withOpacity(.55), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
