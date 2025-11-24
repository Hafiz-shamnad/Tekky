import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';

class AuthApi {
  static const String baseUrl = "http://localhost:5000";

  // ----------------------
  // REGISTER
  // ----------------------
  static Future<Map<String, dynamic>> register(
    String name,
    String username,
    String email,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/api/auth/register");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 201) {
      throw Exception(data["message"] ?? "Registration failed");
    }

    // Save tokens
    await SecureStorage.setAccessToken(data["accessToken"]);
    await SecureStorage.setRefreshToken(data["refreshToken"]);

    // 🔥 Save logged-in user ID
    await SecureStorage.setUserId(data["user"]["id"]);

    return data["user"];
  }

  // ----------------------
  // LOGIN
  // ----------------------
  static Future<Map<String, dynamic>> login(
    String identifier,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/api/auth/login");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"identifier": identifier, "password": password}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Login failed");
    }

    // Save tokens
    await SecureStorage.setAccessToken(data["accessToken"]);
    await SecureStorage.setRefreshToken(data["refreshToken"]);

    // 🔥 Save logged-in user ID
    await SecureStorage.setUserId(data["user"]["id"]);

    return data["user"];
  }

  // ----------------------
  // REFRESH TOKEN
  // ----------------------
  static Future<bool> refreshAccessToken() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    final url = Uri.parse("$baseUrl/api/auth/refresh");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body);

    // Save fresh tokens
    await SecureStorage.setAccessToken(data["accessToken"]);
    await SecureStorage.setRefreshToken(data["refreshToken"]);

    // 🔥 Save user ID from refresh
    if (data["user"] != null && data["user"]["id"] != null) {
      await SecureStorage.setUserId(data["user"]["id"]);
    }

    return true;
  }
}
