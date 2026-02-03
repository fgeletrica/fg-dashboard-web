import '../models/service_request.dart';

class MarketplaceMock {
  static List<ServiceRequest> requests = [
    ServiceRequest(
      id: '1',
      title: 'Troca de disjuntor',
      description: 'Disjuntor desarmando constantemente',
      city: 'São Paulo',
    ),
    ServiceRequest(
      id: '2',
      title: 'Instalar tomada 220V',
      description: 'Para ar-condicionado split',
      city: 'São Paulo',
    ),
  ];
}
