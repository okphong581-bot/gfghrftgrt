import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'network.dart';

class XocketViewModel extends ChangeNotifier {
  final XocketNetwork _api = XocketNetwork();
  
  XocketUser? currentUser;
  List<XocketFeed> feeds = [];
  List<String> friends = [];
  bool isLoading = false;
  Timer? _pollingTimer;

  XocketViewModel() {
    _loadLocalUser();
  }

  Future<void> _loadLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');
    if (username != null && password != null) {
      await login(username, password);
    }
  }

  Future<bool> login(String username, String password) async {
    isLoading = true;
    notifyListeners();
    
    final user = await _api.getUser(username);
    if (user != null && user.password == password) {
      currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('password', password);
      
      await _fetchInitialData();
      _startPolling();
      
      isLoading = false;
      notifyListeners();
      return true;
    }
    
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String username, String password, String displayName) async {
    isLoading = true;
    notifyListeners();
    
    final existingUser = await _api.getUser(username);
    if (existingUser != null) {
      isLoading = false;
      notifyListeners();
      return false; // User exists
    }
    
    final newUser = XocketUser(
      username: username,
      password: password,
      displayName: displayName,
    );
    await _api.saveUser(newUser);
    
    isLoading = false;
    notifyListeners();
    return await login(username, password);
  }

  void logout() async {
    _pollingTimer?.cancel();
    currentUser = null;
    feeds.clear();
    friends.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _fetchInitialData() async {
    if (currentUser == null) return;
    friends = await _api.getFriends(currentUser!.username);
    feeds = await _api.getFeeds(currentUser!.username);
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 7), (timer) async {
      if (currentUser != null) {
        final newFeeds = await _api.getFeeds(currentUser!.username);
        // Optimize UI refresh only if count changes or top ID changes
        if (newFeeds.isNotEmpty && feeds.isNotEmpty) {
           if (newFeeds.first.id != feeds.first.id || newFeeds.length != feeds.length) {
             feeds = newFeeds;
             notifyListeners();
           }
        } else if (newFeeds.length != feeds.length) {
           feeds = newFeeds;
           notifyListeners();
        }
      }
    });
  }

  Future<bool> addFriend(String friendUsername) async {
    final user = await _api.getUser(friendUsername);
    if (user != null && currentUser != null) {
      await _api.addFriend(currentUser!.username, friendUsername);
      friends = await _api.getFriends(currentUser!.username);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> uploadAndSendPhoto(List<int> bytes) async {
    if (currentUser == null || friends.isEmpty) return false;
    
    isLoading = true;
    notifyListeners();

    final url = await UpAnhLayLinkUploader.uploadImage(bytes, "xocket_\${DateTime.now().millisecondsSinceEpoch}.jpg");
    
    if (url != null) {
      final feed = XocketFeed(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderUsername: currentUser!.username,
        imageUrl: url,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      
      // Send to all friends
      for (String friend in friends) {
        await _api.sendFeedToFriend(friend, feed);
      }
      
      // Also save to our own feed to see it
      await _api.sendFeedToFriend(currentUser!.username, feed);
      feeds.insert(0, feed);
      
      isLoading = false;
      notifyListeners();
      return true;
    }
    
    isLoading = false;
    notifyListeners();
    return false;
  }
}
