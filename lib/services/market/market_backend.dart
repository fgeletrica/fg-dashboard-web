import '../../models/service_request.dart';

abstract class MarketBackend {
  Future<List<ServiceRequest>> listRequests({required bool done});
  Future<void> upsert(ServiceRequest doc);
  Future<void> remove(String id);
}
