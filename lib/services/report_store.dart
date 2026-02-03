import '../models/report_models.dart';
import 'report_local_store.dart';

class ReportStore {
  static Future<List<TechnicalReportDoc>> loadReports() async {
    final list = await ReportLocalStore.getReports();
    final items = list.map((e) => TechnicalReportDoc.fromMap(e)).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<void> saveReports(List<TechnicalReportDoc> items) async {
    final list = items.map((e) => e.toMap()).toList();
    await ReportLocalStore.setReports(list);
  }

  static Future<void> upsert(TechnicalReportDoc doc) async {
    final items = await loadReports();
    final idx = items.indexWhere((e) => e.id == doc.id);
    if (idx >= 0) {
      items[idx] = doc;
    } else {
      items.insert(0, doc);
    }
    await saveReports(items);
  }

  static Future<void> removeById(String id) async {
    final items = await loadReports();
    items.removeWhere((e) => e.id == id);
    await saveReports(items);
  }
}
