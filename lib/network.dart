import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class XocketNetwork {
  static const List<String> POTENTIAL_BASE_URLS = [
    "https://appchatai-313e3-default-rtdb.asia-southeast1.firebasedatabase.app/xocket/",
    "https://appchatai-313e3-default-rtdb.firebaseio.com/xocket/",
    "https://appchatai-313e3.firebaseio.com/xocket/"
  ];

  String? _activeBaseUrl;

  Future<String> _getBaseUrl() async {
    if (_activeBaseUrl != null) return _activeBaseUrl!;
    for (String url in POTENTIAL_BASE_URLS) {
      try {
        final response = await http.get(Uri.parse('${url}ping.json')).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          _activeBaseUrl = url;
          return url;
        }
      } catch (e) {
        // Continue to next
      }
    }
    _activeBaseUrl = POTENTIAL_BASE_URLS[0];
    return _activeBaseUrl!;
  }

  // --- USERS ---
  Future<XocketUser?> getUser(String username) async {
    final baseUrl = await _getBaseUrl();
    final response = await http.get(Uri.parse('${baseUrl}users/$username.json'));
    if (response.statusCode == 200 && response.body != 'null') {
      return XocketUser.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<void> saveUser(XocketUser user) async {
    final baseUrl = await _getBaseUrl();
    await http.put(
      Uri.parse('${baseUrl}users/${user.username}.json'),
      body: json.encode(user.toJson()),
    );
  }

  // --- FRIENDS ---
  Future<List<String>> getFriends(String username) async {
    final baseUrl = await _getBaseUrl();
    final response = await http.get(Uri.parse('${baseUrl}friends/$username.json'));
    if (response.statusCode == 200 && response.body != 'null') {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data.keys.toList();
    }
    return [];
  }

  Future<void> addFriend(String username, String friendUsername) async {
    final baseUrl = await _getBaseUrl();
    // 2-way friendship
    await http.put(Uri.parse('${baseUrl}friends/$username/$friendUsername.json'), body: "true");
    await http.put(Uri.parse('${baseUrl}friends/$friendUsername/$username.json'), body: "true");
  }

  // --- FEEDS ---
  Future<List<XocketFeed>> getFeeds(String username) async {
    final baseUrl = await _getBaseUrl();
    final response = await http.get(Uri.parse('${baseUrl}feeds/$username.json'));
    if (response.statusCode == 200 && response.body != 'null') {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = data.values.map((v) => XocketFeed.fromJson(v)).toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    }
    return [];
  }

  Future<void> sendFeedToFriend(String targetUsername, XocketFeed feed) async {
    final baseUrl = await _getBaseUrl();
    await http.put(
      Uri.parse('${baseUrl}feeds/$targetUsername/${feed.id}.json'),
      body: json.encode(feed.toJson()),
    );
  }
}

class UpAnhLayLinkUploader {
  static const String baseUrl = "https://upanhlaylink.com";
  static const String uploadUrl = "https://upanhlaylink.com/upload";

  static Future<String?> uploadImage(List<int> bytes, String filename) async {
    try {
      final sessionResponse = await http.get(Uri.parse(baseUrl));
      final html = sessionResponse.body;
      
      final tokenMatch = RegExp(r'name="csrf-token" content="([^"]+)"').firstMatch(html);
      if (tokenMatch == null) return null;
      final csrfToken = tokenMatch.group(1)!;

      final cookies = sessionResponse.headers['set-cookie']?.split(',').map((e) => e.split(';')[0]).join('; ') ?? "";

      final request = http.MultipartRequest("POST", Uri.parse(uploadUrl));
      request.headers.addAll({
        "X-CSRF-Token": csrfToken,
        "Cookie": cookies,
        "User-Agent": "Mozilla/5.0",
        "Referer": baseUrl,
        "Origin": baseUrl,
      });

      request.fields['server'] = "server_1";
      
      final multipartFile = http.MultipartFile.fromBytes(
        'images[]',
        bytes,
        filename: filename,
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        if (data['results'] != null && data['results'].isNotEmpty && data['results'][0]['success'] == true) {
          return data['results'][0]['url'];
        } else if (data['success'] == true && data['data'] != null) {
          return data['data']['directLink'];
        }
      }
    } catch (e) {
      print("Upload failed: $e");
    }
    return null;
  }
}
