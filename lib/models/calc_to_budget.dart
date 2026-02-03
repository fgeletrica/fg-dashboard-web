class CalcToBudget {
  final String client;
  final double powerW;
  final int voltage;
  final double distanceM;

  final double ib;
  final double cableMm2;
  final int breakerA;
  final double vdropPct;

  const CalcToBudget({
    required this.client,
    required this.powerW,
    required this.voltage,
    required this.distanceM,
    required this.ib,
    required this.cableMm2,
    required this.breakerA,
    required this.vdropPct,
  });
}
