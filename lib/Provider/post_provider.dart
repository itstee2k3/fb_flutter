import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/post_post.dart';
import '../config/config_url.dart';
import 'package:flutter_bui_xuan_thang/models/post_post.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];

  List<Post> get posts => _posts;

  Future<void> fetchPosts() async {
    final String baseUrl = '${Config_URL.baseUrl}api/Post';
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _posts = data.map((item) => Post.fromJson(item)).toList();
      notifyListeners(); // Thông báo thay đổi trạng thái
    } else {
      throw Exception('Failed to load posts');
    }
  }

  void addPost(Post post) {
    _posts.add(post);
    notifyListeners();
  }

  void removePost(Post post) {
    _posts.remove(post);
    notifyListeners();
  }
}
