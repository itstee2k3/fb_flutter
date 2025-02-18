import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';

class UpdatePostScreen extends StatefulWidget {
  final int postId;

  const UpdatePostScreen({super.key, required this.postId});

  @override
  _UpdatePostScreenState createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final String apiUrl = '${Config_URL.baseUrl}api/Post';
  late String userId; // Biến lưu userId

  @override
  void initState() {
    super.initState();
    _fetchPostData(); // Gọi hàm để lấy dữ liệu bài đăng
  }

  // Hàm lấy dữ liệu bài đăng từ API và điền vào các trường
  Future<void> _fetchPostData() async {
    final response = await http.get(
      Uri.parse('$apiUrl/${widget.postId}'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        'ngrok-skip-browser-warning': 'true'
      },
    );

    if (response.statusCode == 200) {
      final postData = json.decode(response.body);
      final post = postData;

      setState(() {
        _titleController.text = post['title'] ?? ''; // Gán giá trị rỗng nếu null
        _descriptionController.text = post['description'] ?? '';
        _imageController.text = post['image'] ?? '';
        userId = post['user']?['id'] ?? ''; // Kiểm tra null cho user và id
      });
    } else {
      print('Failed to load post data');
    }
  }


  // Hàm cập nhật bài đăng
  Future<void> updatePost(BuildContext context) async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final image = _imageController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      showErrorDialog('Title and Description are required.');
      return;
    }

    final Map<String, dynamic> postData = {
      'id': widget.postId,
      'title': title,
      'description': description,
      'image': image.isNotEmpty ? image : null, // Chỉ gửi image nếu không rỗng
      'userId': userId,
      'dateCreate': DateTime.now().toIso8601String(),
    };

    final String jsonPostData = json.encode(postData);

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${widget.postId}'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
        body: jsonPostData,
      );

      if (response.statusCode == 204) {
        showSuccessDialog('Post updated successfully.');
      } else {
        showErrorDialog('Failed to update post: ${response.body}');
      }
    } catch (e) {
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
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(context, true); // Quay lại trang trước với trạng thái cập nhật thành công
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
            onPressed: () => Navigator.pop(context), // Đóng dialog
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
        title: const Text('Update Post'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              onPressed: () {
                updatePost(context);  // Truyền context vào phương thức updatePost
              },
              child: const Text('Update Post'),
            ),
          ],
        ),
      ),
    );
  }
}
