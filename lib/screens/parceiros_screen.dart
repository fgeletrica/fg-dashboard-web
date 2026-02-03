import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';

class ParceirosScreen extends StatefulWidget {
  const ParceirosScreen({super.key});

  @override
  State<ParceirosScreen> createState() => _ParceirosScreenState();
}

class _ParceirosScreenState extends State<ParceirosScreen> {
  static const _kPartnersJson = 'partners_v1';
  static const _kWhats = 'brand_whats_v1';

  List<Map<String, dynamic>> partners = [];
  String whats = "5521997901083";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    whats = (sp.getString(_kWhats) ?? "5521997901083").trim();

    try {
      final raw = sp.getString(_kPartnersJson) ?? "[]";
      final j = jsonDecode(raw);
      if (j is List) {
        partners = j.map((e) => (e as Map).cast<String, dynamic>()).toList();
      }
    } catch (_) {
      partners = [];
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openUrl(String url) async {
    final u = Uri.tryParse(url.trim());
    if (u == null) return;
    await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhats() async {
    final phone = whats.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse(
        "https://wa.me/$phone?text=Quero%20ser%20parceiro%20no%20FG%20El%C3%A9trica");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Text(
              'Aqui você vai colocar lojas, links e descontos pros usuários.\n'
              'Cadastre parceiros no Admin e eles aparecem aqui.',
              style: TextStyle(
                  color: Colors.white.withOpacity(.85),
                  height: 1.3,
                  fontWeight: FontWeight.w700),
            ),
          ),
          if (partners.isEmpty)
            _card(
              child: Row(
                children: [
                  Icon(Icons.storefront, color: AppTheme.gold),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nenhum parceiro cadastrado ainda.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(.85),
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextButton(
                    onPressed: _load,
                    child: Text('Atualizar',
                        style: TextStyle(
                            color: AppTheme.gold, fontWeight: FontWeight.w900)),
                  )
                ],
              ),
            )
          else
            ...partners.map((p) {
              final name = (p["name"] ?? "").toString();
              final url = (p["url"] ?? "").toString();
              final disc = (p["discount"] ?? "").toString();

              return _card(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(.12),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(.35)),
                      ),
                      child: Icon(Icons.handshake, color: AppTheme.gold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          if (disc.trim().isNotEmpty)
                            Text('Desconto: $disc',
                                style: TextStyle(
                                    color: AppTheme.gold,
                                    fontWeight: FontWeight.w900)),
                          if (disc.trim().isEmpty)
                            Text('Parceiro',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(.7))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _openUrl(url),
                      child: const Text('ABRIR',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    )
                  ],
                ),
              );
            }),
          _card(
            child: Row(
              children: [
                Icon(Icons.campaign, color: AppTheme.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Quer aparecer aqui?\nToque para falar no WhatsApp e virar parceiro.',
                    style: TextStyle(
                        color: Colors.white.withOpacity(.85),
                        fontWeight: FontWeight.w800),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _openWhats,
                  child: const Text('CONTATO',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
