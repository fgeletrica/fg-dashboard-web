import 'package:flutter/services.dart';

/// Aceita apenas números, vírgula e ponto
final moneyInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

double parseMoney(String s) {
  return double.tryParse(
        s.replaceAll('.', '').replaceAll(',', '.').trim(),
      ) ??
      0.0;
}
