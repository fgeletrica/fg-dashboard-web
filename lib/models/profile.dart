class Profile {
  final String name;
  final String email;
  final String phone;
  final String company;

  const Profile({
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'company': company,
      };

  static Profile fromJson(Map<String, dynamic> j) => Profile(
        name: (j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        company: (j['company'] ?? '').toString(),
      );
}
