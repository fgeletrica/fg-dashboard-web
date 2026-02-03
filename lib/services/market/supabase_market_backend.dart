import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../models/service_request.dart';
import 'market_backend.dart';

class SupabaseMarketBackend implements MarketBackend {
  bool _isUuid(String s) {
    final r = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return r.hasMatch(s.trim());
  }

  SupabaseClient get _db => Supabase.instance.client;

  @override
  Future<List<ServiceRequest>> listRequests({required bool done}) async {
    final res = await _db
        .from(SupabaseConfig.tableServiceRequests)
        .select()
        .eq('done', done)
        .order('created_at', ascending: false);

    final list = (res as List).cast<dynamic>();
    return list.map((e) {
      final m = (e as Map).cast<String, dynamic>();

      // mapeia campos do Supabase -> modelo
      return ServiceRequest(
        id: (m['id'] ?? '').toString(),
        createdAt: DateTime.tryParse((m['created_at'] ?? '').toString()) ??
            DateTime.now(),
        title: (m['title'] ?? '').toString(),
        description: (m['description'] ?? '').toString(),
        city: (m['city'] ?? '').toString(),
        contactName: (m['contact_name'] ?? '').toString(),
        contactPhone: (m['contact_phone'] ?? '').toString(),
        done: (m['done'] == true),
      );
    }).toList();
  }

  @override
  Future<void> upsert(ServiceRequest doc) async {
    // se o id vier vazio, deixa o Supabase gerar UUID (mas nosso modelo hoje sempre tem id)
    final data = <String, dynamic>{
      if (doc.id.trim().isNotEmpty && _isUuid(doc.id)) 'id': doc.id,
      'title': doc.title,
      'description': doc.description,
      'city': doc.city,
      'contact_name': doc.contactName,
      'contact_phone': doc.contactPhone,
      'done': doc.done,
    };

    await _db.from(SupabaseConfig.tableServiceRequests).upsert(data);
  }

  @override
  Future<void> remove(String id) async {
    await _db.from(SupabaseConfig.tableServiceRequests).delete().eq('id', id);
  }
}
