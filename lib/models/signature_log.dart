class SignatureLog {
  final String budgetId;
  final String clientName;
  final String signedAtIso;
  final String signatureHash;
  final String deviceInfo;
  final String appVersion;

  SignatureLog({
    required this.budgetId,
    required this.clientName,
    required this.signedAtIso,
    required this.signatureHash,
    required this.deviceInfo,
    required this.appVersion,
  });

  Map<String, dynamic> toMap() => {
        'budgetId': budgetId,
        'clientName': clientName,
        'signedAtIso': signedAtIso,
        'signatureHash': signatureHash,
        'deviceInfo': deviceInfo,
        'appVersion': appVersion,
      };

  factory SignatureLog.fromMap(Map<String, dynamic> m) => SignatureLog(
        budgetId: m['budgetId'] ?? '',
        clientName: m['clientName'] ?? '',
        signedAtIso: m['signedAtIso'] ?? '',
        signatureHash: m['signatureHash'] ?? '',
        deviceInfo: m['deviceInfo'] ?? '',
        appVersion: m['appVersion'] ?? '',
      );
}
