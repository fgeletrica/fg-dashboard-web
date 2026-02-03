class ElectricalResult {
  final double corrente;
  final double bitola;
  final int disjuntor;

  ElectricalResult({
    required this.corrente,
    required this.bitola,
    required this.disjuntor,
  });
}

class ElectricalCalc {
  static ElectricalResult calcular({
    required double potenciaW,
    required double tensaoV,
    required double distanciaM,
  }) {
    final corrente = potenciaW / tensaoV;

    double bitola;
    if (corrente <= 15) {
      bitola = 1.5;
    } else if (corrente <= 21) {
      bitola = 2.5;
    } else if (corrente <= 28) {
      bitola = 4.0;
    } else if (corrente <= 36) {
      bitola = 6.0;
    } else {
      bitola = 10.0;
    }

    final disjuntor = corrente <= 20
        ? 20
        : corrente <= 25
            ? 25
            : corrente <= 32
                ? 32
                : 40;

    return ElectricalResult(
      corrente: corrente,
      bitola: bitola,
      disjuntor: disjuntor,
    );
  }
}
