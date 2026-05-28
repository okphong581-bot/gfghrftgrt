class XocketUser {
  String username;
  String password;
  String displayName;
  String avatarUrl;

  XocketUser({
    required this.username,
    required this.password,
    required this.displayName,
    this.avatarUrl = "https://cdn-icons-png.flaticon.com/512/149/149071.png",
  });

  factory XocketUser.fromJson(Map<String, dynamic> json) {
    return XocketUser(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      displayName: json['displayName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
    };
  }
}

class XocketFeed {
  String id;
  String senderUsername;
  String imageUrl;
  int timestamp;

  XocketFeed({
    required this.id,
    required this.senderUsername,
    required this.imageUrl,
    required this.timestamp,
  });

  factory XocketFeed.fromJson(Map<String, dynamic> json) {
    return XocketFeed(
      id: json['id'] ?? '',
      senderUsername: json['senderUsername'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderUsername': senderUsername,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }
}
