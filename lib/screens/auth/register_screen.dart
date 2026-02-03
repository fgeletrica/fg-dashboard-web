import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "package:meu_ajudante_fg/core/app_theme.dart";
import "package:meu_ajudante_fg/routes/app_routes.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _industrial = true;

  // residencial: client/pro
  String _resRole = "client"; // "client" | "pro"

  final _name = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();

  // residencial
  final _email = TextEditingController();

  // industrial
  final _matricula = TextEditingController();

  final _pass = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _phone.dispose();
    _email.dispose();
    _matricula.dispose();
    _pass.dispose();
    super.dispose();
  }

  String _digits(String s) => s.replaceAll(RegExp(r"[^0-9]"), "");
  String _industrialEmail(String mat) => "${_digits(mat)}@fg.com";

  InputDecoration _dec({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: AppTheme.bg.withOpacity(.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _submit() async {
    if (_busy) return;

    final name = _name.text.trim();
    final city = _city.text.trim();
    final phone = _phone.text.trim();
    final pass = _pass.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Informe o nome.")));
      return;
    }

    if (pass.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Senha muito curta (mínimo 6 caracteres).")));
      return;
    }

    String emailToUse;

    final meta = <String, dynamic>{
      "name": name,
      "city": city,
      "phone": phone,
      "display_name": name, // usado no perfil
    };

    if (_industrial) {
      final m = _digits(_matricula.text);
      if (m.length != 7) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Matrícula inválida. Use 7 números (ex: 6131450).")));
        return;
      }

      emailToUse = _industrialEmail(m);

      meta.addAll({
        "account_type": "industrial",
        "matricula": m, // pro trigger criar "Nome (matricula)"
        // role no industrial é gerido pelo industrial_user_roles (auto operator)
      });
    } else {
      final e = _email.text.trim().toLowerCase();
      if (!e.contains("@") || !e.contains(".")) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Email inválido.")));
        return;
      }
      emailToUse = e;

      meta.addAll({
        "account_type": "residential",
        // ✅ ISSO AQUI é o que faltava: define client/pro no profile_on_auth_signup...
        "role": _resRole == "pro" ? "pro" : "client",
      });
    }

    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: emailToUse,
        password: pass,
        data: meta,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_industrial
            ? "Conta industrial criada. Login: matrícula + senha."
            : (_resRole == "pro"
                ? "Conta Profissional criada."
                : "Conta Cliente criada.")),
      ));

      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao criar conta: $e")));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _segmentAccess() {
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
                    "Industrial",
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
                    "Residencial/Predial",
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

  Widget _segmentResidentialRole() {
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
              onTap: () => setState(() => _resRole = "client"),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _resRole == "client"
                      ? AppTheme.gold.withOpacity(.95)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    "Cliente",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _resRole == "client"
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
              onTap: () => setState(() => _resRole = "pro"),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _resRole == "pro"
                      ? AppTheme.gold.withOpacity(.95)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    "Profissional",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _resRole == "pro"
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text("Criar conta"),
      ),
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
                Text(
                  "Escolha o tipo de acesso e preencha seus dados",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.8),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _segmentAccess(),
                const SizedBox(height: 14),
                TextField(
                  controller: _name,
                  decoration: _dec(label: "Nome", icon: Icons.person),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _city,
                  decoration:
                      _dec(label: "Cidade/Bairro", icon: Icons.location_on),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phone,
                  decoration:
                      _dec(label: "WhatsApp (com DDD)", icon: Icons.chat),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 10),
                if (_industrial) ...[
                  TextField(
                    controller: _matricula,
                    decoration: _dec(
                      label: "Matrícula",
                      hint: "Ex: 6131450",
                      icon: Icons.badge,
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  _segmentResidentialRole(),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _email,
                    decoration: _dec(label: "Email", icon: Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: _pass,
                  decoration: _dec(label: "Senha", icon: Icons.lock),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
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
                    onPressed: _busy ? null : _submit,
                    child: Text(
                      _busy ? "Criando..." : "Criar conta",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _industrial
                      ? "Industrial: login é pela matrícula + senha."
                      : (_resRole == "pro"
                          ? "Residencial: conta Profissional (email + senha)."
                          : "Residencial: conta Cliente (email + senha)."),
                  style: TextStyle(
                    color: Colors.white.withOpacity(.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
