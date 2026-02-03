import '../../models/service_request.dart';
import '../service_requests_store.dart';
import 'market_backend.dart';

class LocalMarketBackend implements MarketBackend {
  @override
  Future<List<ServiceRequest>> listRequests({required bool done}) async {
    final all = await ServiceRequestsStore.load();
    return all.where((e) => e.done == done).toList();
  }

  @override
  Future<void> upsert(ServiceRequest doc) async {
    await ServiceRequestsStore.upsert(doc);
  }

  @override
  Future<void> remove(String id) async {
    await ServiceRequestsStore.remove(id);
  }
}
