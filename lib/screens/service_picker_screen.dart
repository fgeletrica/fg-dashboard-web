import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/service_templates.dart';

class ServicePickerScreen extends StatefulWidget {
  const ServicePickerScreen({super.key});

  @override
  State<ServicePickerScreen> createState() => _ServicePickerScreenState();
}

class _ServicePickerScreenState extends State<ServicePickerScreen> {
  final _q = TextEditingController();
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _q.addListener(
        () => setState(() => _filter = _q.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ServiceTemplates.residential;
    final filtered = all.where((s) {
      final hay =
          ('${s.title} ${s.description} ${s.priceSuggested}').toLowerCase();
      return hay.contains(_filter);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Catálogo de Serviços'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _q,
            decoration: InputDecoration(
              hintText: 'Buscar serviço (ex: tomada, chuveiro, quadro...)',
              filled: true,
              fillColor: AppTheme.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.gold.withOpacity(.65)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...filtered.map((s) => _card(
                title: s.title,
                sub:
                    '${s.description} • Sugestão: R\$ ${s.priceSuggested.toStringAsFixed(2)}',
                onTap: () => Navigator.pop(context, s),
              )),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Nada encontrado.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(.7),
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _card(
      {required String title,
      required String sub,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border.withOpacity(.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.gold.withOpacity(.35)),
              ),
              child: Icon(Icons.handyman_outlined, color: AppTheme.gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(sub,
                        style: TextStyle(
                            color: Colors.white.withOpacity(.65),
                            fontWeight: FontWeight.w600)),
                  ]),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(.6)),
          ],
        ),
      ),
    );
  }
}
