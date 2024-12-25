import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config_url.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'account_screen.dart';

Future<void> checkToken(String token) async {
  try {
    // Giải mã token
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    // Kiểm tra nội dung của token
    print(decodedToken); // In ra toàn bộ nội dung payload của token

    // Lấy userId từ decoded token
    String userId = decodedToken['userId'] ?? "";
    if (userId.isEmpty) {
      print("User ID not found in token.");
    } else {
      print("User ID: $userId");
    }

    // Lưu userId và token vào SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('userId', userId);

    // Kiểm tra thời gian hết hạn của token
    bool isExpired = JwtDecoder.isExpired(token);
    if (isExpired) {
      print("Token has expired.");
    } else {
      print("Token is valid.");
    }
  } catch (e) {
    print("Error decoding token: $e");
  }
}


class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  bool isLoading = false; // Trạng thái tải dữ liệu
  final String apiUrl = '${Config_URL.baseUrl}api/Post'; // URL API

  Future<void> createPost() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final image = _imageController.text.trim();

    // Kiểm tra nhập liệu
    if (title.isEmpty || description.isEmpty) {
      showErrorDialog('Title and Description are required.');
      return;
    }

    // Lấy userId và token từ SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('jwt_token');

    // Kiểm tra nếu không có userId hoặc token
    if (userId == null || userId.isEmpty || token == null || token.isEmpty) {
      showErrorDialog('User is not logged in. Please log in first.');
      return;
    }

    // Kiểm tra token trước khi gửi yêu cầu
    checkToken(token);  // Kiểm tra token

    final Map<String, dynamic> postData = {
      'userId': userId,  // Lấy userId đã lưu
      'title': title,
      'description': description,
      'image': image.isNotEmpty ? image : null, // Optional image
      'dateCreate': DateTime.now().toIso8601String(),
    };

    setState(() {
      isLoading = true; // Hiển thị chỉ báo tải
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // Thêm token vào header
        },
        body: json.encode(postData),
      );

      setState(() {
        isLoading = false; // Tắt chỉ báo tải
      });

      if (response.statusCode == 201) {
        // final Map<String, dynamic> newPost = json.decode(response.body);
        showSuccessDialog('Post created successfully.');
        // Navigator.pop(context); // Quay lại sau khi tạo bài đăng
      } else {
        showErrorDialog('Failed to create post: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Tắt chỉ báo tải
      });
      showErrorDialog('An error occurred: $e');
    }
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);  // Đóng dialog
              Navigator.pop(context, true);  // Quay lại trang AccountScreen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị khi đang tải
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: createPost,
                child: const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
