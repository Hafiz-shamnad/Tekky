import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/xp_api.dart';
import '../../../data/models/xp_model.dart';

final xpProvider = FutureProvider<XPModel>((ref) async {
  return XpApi.getXP();
});

final xpClaimProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return XpApi.claimDaily();
});
