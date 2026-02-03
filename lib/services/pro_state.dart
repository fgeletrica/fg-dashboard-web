import 'package:flutter/material.dart';
import 'local_store.dart';

class ProState extends ChangeNotifier {
  bool _isPro = false;

  bool get isPro => _isPro;

  Future<void> load() async {
    _isPro = await LocalStore.isPro();
    notifyListeners();
  }

  Future<void> activate() async {
    await LocalStore.setPro(true);
    _isPro = true;
    notifyListeners();
  }
}
