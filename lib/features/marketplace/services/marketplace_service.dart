import 'dart:math';
import '../models/service_request.dart';
import '../mock/marketplace_mock.dart';

class MarketplaceService {
  static List<ServiceRequest> feed(String city) {
    return MarketplaceMock.requests
        .where((r) => r.city == city && !r.done)
        .toList();
  }

  static List<ServiceRequest> myRequests() {
    return MarketplaceMock.requests;
  }

  static void addRequest(String title, String desc, String city) {
    MarketplaceMock.requests.insert(
      0,
      ServiceRequest(
        id: Random().nextInt(999999).toString(),
        title: title,
        description: desc,
        city: city,
      ),
    );
  }

  static void markDone(String id) {
    final idx =
        MarketplaceMock.requests.indexWhere((element) => element.id == id);
    if (idx != -1) {
      MarketplaceMock.requests[idx] =
          MarketplaceMock.requests[idx].copyWith(done: true);
    }
  }
}
