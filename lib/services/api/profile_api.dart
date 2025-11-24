import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';

class ProfileApi {
  static const String baseUrl = "http://localhost:5000";

  static Future<Map<String, dynamic>> getMyProfile() async {
    final accessToken = await SecureStorage.getAccessToken();

    final res = await http.get(
      Uri.parse("$baseUrl/api/profile/me"),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 401) {
      throw Exception("Unauthorized – token expired?");
    }

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? name,
    String? avatarUrl,
    String? bio,
  }) async {
    final accessToken = await SecureStorage.getAccessToken();

    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (name != null) body['name'] = name;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    if (bio != null) body['bio'] = bio;

    final res = await http.put(
      Uri.parse("$baseUrl/api/profile"),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      final err = jsonDecode(res.body);
      throw Exception(err["message"] ?? "Failed to update profile");
    }
  }

  static Future<bool> checkUsernameAvailability(String username) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/auth/check-username?username=$username"),
    );

    final data = jsonDecode(res.body);
    return data["available"] == true;
  }
}
