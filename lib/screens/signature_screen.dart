import 'package:meu_ajudante_fg/services/pro_guard.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _c = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_c.isEmpty) {
      Navigator.pop(context, null);
      return;
    }
    final bytes = await _c.toPngBytes();
    if (bytes == null) {
      Navigator.pop(context, null);
      return;
    }
    final b64 = base64Encode(bytes);
    Navigator.pop(context, b64);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinatura do cliente'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SALVAR',
                style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: Signature(controller: _c, backgroundColor: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _c.clear(),
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
