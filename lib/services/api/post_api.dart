import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';

class PostApi {
  static const baseUrl = "http://localhost:5000";

  // ----------------------------------------------
  // GET FEED
  // ----------------------------------------------
  static Future<List<dynamic>> getFeed() async {
    final token = await SecureStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("$baseUrl/api/posts"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);
    return data['posts'];
  }

  // ----------------------------------------------
  // CREATE POST
  // ----------------------------------------------
  static Future<Map<String, dynamic>> createPost(String content) async {
    final token = await SecureStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/posts"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"content": content}),
    );

    return jsonDecode(response.body);
  }

  // ----------------------------------------------
  // LIKE / UNLIKE POST
  // ----------------------------------------------
  static Future<Map<String, dynamic>> toggleLike(String postId) async {
    final token = await SecureStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/posts/$postId/like"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  // ----------------------------------------------
  // ADD COMMENT
  // ----------------------------------------------
  static Future<void> addComment(String postId, String text) async {
    final token = await SecureStorage.getAccessToken();

    await http.post(
      Uri.parse("$baseUrl/api/comments/$postId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"text": text}),
    );
  }

  // ----------------------------------------------
  // DELETE POST
  // ----------------------------------------------
  static Future<bool> deletePost(String postId) async {
    final token = await SecureStorage.getAccessToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/api/posts/$postId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }

  // ----------------------------------------------
  // REPORT POST
  // ----------------------------------------------
  static Future<bool> reportPost(String postId) async {
    final token = await SecureStorage.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/posts/$postId/report"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }
}
