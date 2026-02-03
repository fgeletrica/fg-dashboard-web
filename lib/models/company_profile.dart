class CompanyProfile {
  final String name;
  final String? cnpj;
  final String? phone;
  final String? logoPath;

  CompanyProfile({
    required this.name,
    this.cnpj,
    this.phone,
    this.logoPath,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'cnpj': cnpj,
        'phone': phone,
        'logoPath': logoPath,
      };

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      name: map['name'] ?? '',
      cnpj: map['cnpj'],
      phone: map['phone'],
      logoPath: map['logoPath'],
    );
  }
}
