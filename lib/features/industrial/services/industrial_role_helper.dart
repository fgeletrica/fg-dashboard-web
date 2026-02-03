class IndustrialRoleHelper {
  static const roles = ["operator", "technician", "admin", "supervisor"];

  static List<String> editableRolesFor(String actorRole) {
    switch (actorRole) {
      case "supervisor":
        return ["operator", "technician", "admin"];
      case "admin":
        return ["operator", "admin"];
      default:
        return [];
    }
  }

  static bool canEdit(String actorRole) {
    return actorRole == "supervisor" || actorRole == "admin";
  }
}
