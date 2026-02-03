import '../services/pro_guard.dart';
import 'package:flutter/material.dart';

import '../services/profile_store.dart';
import 'package:meu_ajudante_fg/routes/app_routes.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _name = TextEditingController();
  final _cnpj = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();

  bool _loading = true;
  bool _hasPro = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await ProfileStore.loadCompanyProfile();
    final hasPro = await ProGuard.hasPro();

    _name.text = (m['companyName'] ?? '').toString();
    _cnpj.text = (m['cnpj'] ?? '').toString();
    _phone.text = (m['phone'] ?? '').toString();
    _email.text = (m['email'] ?? '').toString();
    _address.text = (m['address'] ?? '').toString();

    if (!mounted) return;
    setState(() {
      _hasPro = hasPro;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final hasPro = await ProGuard.hasPro();
    if (!hasPro) {
      if (!mounted) return;
      Navigator.of(context).pushNamed(AppRoutes.paywall);
      return;
    }

    final data = <String, dynamic>{
      'companyName': _name.text.trim(),
      'cnpj': _cnpj.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim(),
      'address': _address.text.trim(),
      // logoB64 fica pra depois (quando a gente ligar logo no PDF)
      'logoB64': '',
    };

    await ProfileStore.saveCompanyProfile(data);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados da empresa salvos ✅')),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _cnpj.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados da empresa'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.save),
            tooltip: _hasPro ? 'Salvar' : 'PRO: salvar dados da empresa',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_hasPro)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Salvar dados da empresa é PRO.\n(Serve pra colocar no PDF: logo, CNPJ, contato.)',
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.paywall),
                    child: const Text('VER PRO'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Nome da empresa',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cnpj,
            decoration: const InputDecoration(
              labelText: 'CNPJ/CPF',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(
              labelText: 'Telefone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            decoration: const InputDecoration(
              labelText: 'Endereço',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(_hasPro ? 'Salvar' : 'Salvar (PRO)'),
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
