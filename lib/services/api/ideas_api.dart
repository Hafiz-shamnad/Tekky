import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';

class IdeasApi {
  static const String baseUrl = "http://localhost:5000";

  /// CREATE IDEA
  static Future<bool> createIdea(
    String title,
    String description,
    List<String> techStacks,
  ) async {
    final token = await SecureStorage.getAccessToken();
    if (token == null) return false;

    final res = await http.post(
      Uri.parse("$baseUrl/api/ideas"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "title": title,
        "description": description,
        "techStacks": techStacks,
      }),
    );

    return res.statusCode == 201;
  }

  /// FETCH IDEAS (NO TOKEN REQUIRED)
  static Future<List<dynamic>> getIdeas() async {
    final token = await SecureStorage.getAccessToken();

    final res = await http.get(
      Uri.parse("$baseUrl/api/ideas"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load ideas (${res.statusCode})");
    }
  }
  
  static Future<String?> sendInterest(String ideaId) async {
  final token = await SecureStorage.getAccessToken();
  if (token == null) return "NOT_AUTHENTICATED";

  final res = await http.post(
    Uri.parse("$baseUrl/api/ideas/$ideaId/interest"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (res.statusCode == 200) return "SUCCESS";
  return res.body; // error message from backend
}

}
