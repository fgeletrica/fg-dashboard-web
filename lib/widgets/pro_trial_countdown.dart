import 'dart:async';
import 'package:flutter/material.dart';
import '../services/pro_access.dart';

class ProTrialCountdown extends StatefulWidget {
  const ProTrialCountdown({super.key, this.style});

  final TextStyle? style;

  @override
  State<ProTrialCountdown> createState() => _ProTrialCountdownState();
}

class _ProTrialCountdownState extends State<ProTrialCountdown> {
  Timer? _t;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    final d = await ProAccess.trialRemaining();
    if (!mounted) return;
    setState(() => _left = d);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txt = ProAccess.formatDuration(_left);
    return Text(txt, style: widget.style);
  }
}
