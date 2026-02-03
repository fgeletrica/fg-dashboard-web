import "dart:convert";

class ServiceRequest {
  final String id;
  final DateTime createdAt;

  String title;
  String description;

  String city; // cidade/bairro
  String contactName;
  String contactPhone; // WhatsApp
  bool done;

  ServiceRequest({
    required this.id,
    required this.createdAt,
    this.title = "",
    this.description = "",
    this.city = "",
    this.contactName = "",
    this.contactPhone = "",
    this.done = false,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "createdAt": createdAt.toIso8601String(),
        "title": title,
        "description": description,
        "city": city,
        "contactName": contactName,
        "contactPhone": contactPhone,
        "done": done,
      };

  factory ServiceRequest.fromMap(Map<String, dynamic> m) => ServiceRequest(
        id: (m["id"] ?? "").toString(),
        createdAt: DateTime.tryParse((m["createdAt"] ?? "").toString()) ??
            DateTime.now(),
        title: (m["title"] ?? "").toString(),
        description: (m["description"] ?? "").toString(),
        city: (m["city"] ?? "").toString(),
        contactName: (m["contactName"] ?? "").toString(),
        contactPhone: (m["contactPhone"] ?? "").toString(),
        done: (m["done"] == true),
      );

  String toJson() => jsonEncode(toMap());
  factory ServiceRequest.fromJson(String s) =>
      ServiceRequest.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
