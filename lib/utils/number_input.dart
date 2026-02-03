import 'package:flutter/services.dart';

final numberInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[0-9.]'),
);
