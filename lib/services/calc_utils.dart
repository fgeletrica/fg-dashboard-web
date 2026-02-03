// === Seleção inteligente de disjuntor ===
int disjuntorPadrao(double corrente) {
  final padroes = [6, 10, 16, 20, 25, 32, 40, 50, 63];

  for (final d in padroes) {
    if (d >= corrente) return d;
  }
  return padroes.last;
}

// === Verifica se disjuntor ficou muito acima da corrente ===
bool disjuntorMuitoAcima(double corrente, int disjuntor) {
  if (corrente <= 0) return false;
  return disjuntor > (corrente * 1.20);
}
