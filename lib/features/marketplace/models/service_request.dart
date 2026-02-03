class ServiceRequest {
  final String id;
  final String title;
  final String description;
  final String city;
  final bool done;
  final DateTime createdAt;

  ServiceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    this.done = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ServiceRequest copyWith({bool? done}) {
    return ServiceRequest(
      id: id,
      title: title,
      description: description,
      city: city,
      done: done ?? this.done,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'city': city,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ServiceRequest.fromMap(Map<String, dynamic> m) {
    return ServiceRequest(
      id: m['id'],
      title: m['title'],
      description: m['description'],
      city: m['city'],
      done: m['done'] ?? false,
      createdAt: DateTime.parse(m['createdAt']),
    );
  }
}
