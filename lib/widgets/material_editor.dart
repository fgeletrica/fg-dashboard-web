import 'package:flutter/material.dart';
import '../models/material_item.dart';

class MaterialEditor extends StatefulWidget {
  final void Function(MaterialItem) onAdd;
  const MaterialEditor({super.key, required this.onAdd});

  @override
  State<MaterialEditor> createState() => _MaterialEditorState();
}

class _MaterialEditorState extends State<MaterialEditor> {
  final _nomeCtrl = TextEditingController();
  final _qtdCtrl = TextEditingController(text: '1');
  final _precoCtrl = TextEditingController(text: '0');
  String _unidade = 'm'; // m ou un

  double _toDouble(String s) =>
      double.tryParse(s.replaceAll(',', '.').trim()) ?? 0.0;

  double _parseMoney(String s) {
    var t = s.trim();
    t = t.replaceAll('R\$', '').replaceAll(' ', '');
    // remove separador de milhar
    t = t.replaceAll('.', '');
    // decimal BR -> US
    t = t.replaceAll(',', '.');
    return double.tryParse(t) ?? 0.0;
  }

  double get quantidade => _toDouble(_qtdCtrl.text);
  double get precoUnitario => _parseMoney(_precoCtrl.text);
  double get total => quantidade * precoUnitario;

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      );

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _qtdCtrl.dispose();
    _precoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nomeCtrl,
          decoration: _dec('Material'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _qtdCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _dec('Quantidade'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _unidade,
                decoration: _dec('Unidade'),
                items: const [
                  DropdownMenuItem(value: 'm', child: Text('metro')),
                  DropdownMenuItem(value: 'un', child: Text('unidade')),
                ],
                onChanged: (v) => setState(() => _unidade = v ?? 'm'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _precoCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _dec('Preço unitário (R\$)'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Total: R\$ ${total.toStringAsFixed(2).replaceAll(".", ",")}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: () {
              final nome = _nomeCtrl.text.trim();
              if (nome.isEmpty) return;

              widget.onAdd(
                MaterialItem(
                  nome: nome,
                  unidade: _unidade,
                  quantidade: quantidade <= 0 ? 1 : quantidade,
                  precoUnitario: precoUnitario < 0 ? 0 : precoUnitario,
                ),
              );

              _nomeCtrl.clear();
              _qtdCtrl.text = '1';
              _precoCtrl.text = '0';
              setState(() {});
            },
            child: const Text('Adicionar material'),
          ),
        ),
      ],
    );
  }
}
