import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';
import '../../data/models/xp_model.dart';

class XpApi {
  static const baseUrl = "http://localhost:5000";

  static Future<XPModel> getXP() async {
    final token = await SecureStorage.getAccessToken();

    final res = await http.get(
      Uri.parse("$baseUrl/api/xp/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);
    return XPModel.fromJson(data);
  }

  static Future<Map<String, dynamic>> claimDaily() async {
    final token = await SecureStorage.getAccessToken();

    final res = await http.post(
      Uri.parse("$baseUrl/api/xp/claim-daily"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(res.body);
  }
}
