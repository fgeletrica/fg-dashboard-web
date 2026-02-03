import "package:flutter/material.dart";
import "industrial_kpi_service.dart";
import "industrial_context.dart";

class IndustrialKpiController extends ChangeNotifier {
  IndustrialKpis? kpis;
  bool loading = false;

  Future<void> load(IndustrialContext ctx) async {
    loading = true;
    notifyListeners();
    try {
      kpis = await IndustrialKpiService.fetchForSite(siteId: ctx.siteId);
    } catch (_) {
      kpis = null;
    }
    loading = false;
    notifyListeners();
  }
}
