import "../models/service_request.dart";
import "local_store.dart";

class ServiceRequestsStore {
  static Future<List<ServiceRequest>> load() async {
    final list = await LocalStore.getServiceRequests();
    final items = list.map((e) => ServiceRequest.fromMap(e)).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<void> saveAll(List<ServiceRequest> items) async {
    final list = items.map((e) => e.toMap()).toList();
    await LocalStore.setServiceRequests(list);
  }

  static Future<void> upsert(ServiceRequest doc) async {
    final items = await load();
    final idx = items.indexWhere((e) => e.id == doc.id);
    if (idx >= 0) {
      items[idx] = doc;
    } else {
      items.insert(0, doc);
    }
    await saveAll(items);
  }

  static Future<void> remove(String id) async {
    final items = await load();
    items.removeWhere((e) => e.id == id);
    await saveAll(items);
  }
}
