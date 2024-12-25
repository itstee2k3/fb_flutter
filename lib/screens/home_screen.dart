import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import '../models/post_post.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<List<Post>> fetchPosts() async {
    final String baseUrl = '${Config_URL.baseUrl}api/Post'; // Đảm bảo URL chính xác
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        'ngrok-skip-browser-warning': 'true'
      },
    );

    print('Response headers: ${response.headers}');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');  // In ra body của phản hồi để kiểm tra

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Post.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Post>>(
        future: fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final post = snapshot.data![index];
                String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(post.dateCreate);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Hiển thị avatar người dùng
                            CircleAvatar(
                              backgroundImage: post.user.avatar != null
                                  ? NetworkImage(post.user.avatar!)  // Dùng URL avatar
                                  : const AssetImage('assets/default_profile.png') as ImageProvider,
                              radius: 25,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.user.userName,  // Hiển thị tên người dùng
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  formattedDate,  // Hiển thị ngày tạo bài đăng
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          post.description ?? 'No description',  // Hiển thị mô tả bài đăng
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        post.image != null
                            ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8), // Bo tròn góc nếu cần
                            child: Image.network(
                              post.image!,
                              fit: BoxFit.contain, // Thay đổi cách hiển thị ảnh
                              width: double.infinity,
                              height: 300, // Đặt chiều cao cố định hoặc sử dụng chiều cao linh hoạt
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Text('Image failed to load'),
                              ),
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                // Handle Like action
                              },
                              icon: const Icon(Icons.thumb_up_alt_outlined),
                              label: const Text('Like'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                // Handle Comment action
                              },
                              icon: const Icon(Icons.comment_outlined),
                              label: const Text('Comment'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                // Handle Share action
                              },
                              icon: const Icon(Icons.share_outlined),
                              label: const Text('Share'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}
