class IndustrialDiagnostic {
  final String id;
  final int createdAtMs;

  final String orgId;
  final String siteId;

  final String shift; // Manhã/Tarde/Noite (auto)
  final String line;

  final String machineGroup;
  final String machineItem;

  final String problem;
  final String actionTaken;

  final bool hasRootCause;
  final String rootCause;

  final String createdBy;
  final String createdByName;

  IndustrialDiagnostic({
    required this.id,
    required this.createdAtMs,
    required this.orgId,
    required this.siteId,
    required this.shift,
    required this.line,
    required this.machineGroup,
    required this.machineItem,
    required this.problem,
    required this.actionTaken,
    required this.hasRootCause,
    required this.rootCause,
    required this.createdBy,
    required this.createdByName,
  });

  String get machineFinal =>
      machineItem.trim().isEmpty ? machineGroup : machineItem;

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'created_at_ms': createdAtMs,
        'org_id': orgId,
        'site_id': siteId,
        'shift': shift,
        'line': line,
        'machine_group': machineGroup,
        'machine': machineFinal,
        'problem': problem,
        'action_taken': actionTaken,
        'has_root_cause': hasRootCause,
        'root_cause': rootCause,
        'closed': true,
        'created_by': createdBy,
        'created_by_name': createdByName,
      };
}
