import 'package:flutter/material.dart';

import 'package:meu_ajudante_fg/core/app_theme.dart';
import 'package:meu_ajudante_fg/services/pro_guard.dart';
import 'package:meu_ajudante_fg/services/signature_store.dart';

class ValidateDocumentScreen extends StatefulWidget {
  const ValidateDocumentScreen({super.key});

  @override
  State<ValidateDocumentScreen> createState() => _ValidateDocumentScreenState();
}

class _ValidateDocumentScreenState extends State<ValidateDocumentScreen> {
  final _hashCtrl = TextEditingController();
  bool _loading = false;

  String _status = '';
  Map<String, dynamic>? _log;

  @override
  void dispose() {
    _hashCtrl.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    final hash = _hashCtrl.text.trim().toLowerCase();
    if (hash.isEmpty) {
      setState(() {
        _status = 'Cole o Hash SHA-256 (do QR) para validar.';
        _log = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _status = '';
      _log = null;
    });

    try {
      final found = await SignatureStore.findLegalLogByHash(hash);
      if (!mounted) return;

      if (found == null) {
        setState(() {
          _status = '❌ NÃO ENCONTRADO: não existe log local com este hash.';
          _log = null;
        });
      } else {
        setState(() {
          _status =
              '✅ VÁLIDO: hash confere com log jurídico salvo no aparelho.';
          _log = found;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = '⚠️ Erro ao validar: $e';
        _log = null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Validar documento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border.withOpacity(.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cole o Hash SHA-256 (do QR Code)',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _hashCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Ex: a3f9c2e7... (64 caracteres)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () {
                              ProGuard.requirePro(context, _validate);
                            },
                      child: _loading
                          ? const Text('Validando...')
                          : const Text('Validar (PRO)'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_status.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border.withOpacity(.35)),
                ),
                child: Text(_status),
              ),
            const SizedBox(height: 10),
            if (_log != null)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border.withOpacity(.35)),
                  ),
                  child: ListView(
                    children: [
                      const Text(
                        'Detalhes do log',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      _kv('Orçamento', (_log!['budgetId'] ?? '').toString()),
                      _kv('Cliente', (_log!['clientName'] ?? '').toString()),
                      _kv(
                        'Assinado em',
                        (_log!['signedAtIso'] ?? _log!['signedAt'] ?? '')
                            .toString(),
                      ),
                      _kv(
                        'Dispositivo',
                        (_log!['deviceInfo'] ?? _log!['device'] ?? 'unknown')
                            .toString(),
                      ),
                      _kv('App', (_log!['appVersion'] ?? 'unknown').toString()),
                      const SizedBox(height: 10),
                      const Text(
                        'Obs: a validação usa os logs locais salvos no aparelho onde o PDF foi gerado.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(child: Text(v.isEmpty ? '—' : v)),
        ],
      ),
    );
  }
}
