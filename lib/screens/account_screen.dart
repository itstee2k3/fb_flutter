import 'dart:io';

import 'package:flutter/material.dart';
import '../config/config_url.dart';
import '../models/post_post.dart';
import '../models/user_post.dart';
import 'create_post_screen.dart'; // Import trang tạo bài đăng
import 'update_post_screen.dart'; // Import trang cập nhật bài đăng
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_screen.dart'; // Màn hình đăng nhập (để điều hướng khi logout)
import 'package:shared_preferences/shared_preferences.dart'; // Để lưu và lấy UserId

class AccountScreen extends StatefulWidget {
  AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}
// Hàm lấy UserId từ SharedPreferences
Future<String?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId'); // 'userId' là key đã lưu
}
class _AccountScreenState extends State<AccountScreen> {
  final String apiUrl = '${Config_URL.baseUrl}api/Post';
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  late User user; // Biến lưu trữ thông tin người dùng
  String? token; // Biến lưu trữ token của người dùng
  String? errorMessage; // Biến để lưu thông báo lỗi khi gặp sự cố

  // Hàm fetchPosts để tải dữ liệu
  Future<void> fetchPosts(String userId) async {
    final response = await http.get(
        Uri.parse('${Config_URL.baseUrl}api/Post/user/$userId'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        'ngrok-skip-browser-warning': 'true'
      },
    );

    if (response.statusCode == 200) {
      final postsData = json.decode(response.body);
      setState(() {
        posts = List<Map<String, dynamic>>.from(postsData);
        isLoading = false;
      });
    } else {
      print('Error fetching posts: ${response.statusCode}');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load posts';
      });
    }
  }

  // Hàm lấy token từ SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Hàm xóa token khỏi SharedPreferences khi người dùng đăng xuất
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('userId');

    // Điều hướng về màn hình login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Hàm fetchUser để tải thông tin người dùng
  Future<void> fetchUser() async {
    try {
      final response = await http.get(
        Uri.parse('${Config_URL.baseUrl}api/User/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          user = User.fromJson(data);
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load user data: ${response.body}';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        errorMessage = 'Error occurred while fetching user data: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getToken().then((tokenValue) {
      if (tokenValue != null) {
        setState(() {
          token = tokenValue;
        });
        getUserId().then((userId) {
          if (userId != null) {
            fetchPosts(userId); // Tải bài đăng nếu có userId
            fetchUser(); // Tải thông tin người dùng
          } else {
            setState(() {
              isLoading = false;
              errorMessage = 'UserId not found. Please login again.';
            });
          }
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Token not found. Please login again.';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                user != null
                    ? Text(
                  'Name: ${user.userName}',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                )
                    : Text('Loading user data...'),
                SizedBox(height: 8),
                user != null
                    ? Text('Email: ${user.email}',
                    style: TextStyle(fontSize: 16))
                    : Text('Loading email...'),
              ],
            ),
          ),
          posts.isEmpty
              ? Center(child: const Text('No posts available.'))
              : Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: post['image'] != null
                        ? Image.network(post['image'],
                        width: 50, height: 50)
                        : Icon(Icons.image, size: 50),
                    title: Text(
                        'Title: ${post['title']}'),
                    subtitle: Text(
                        'Description: ${post['description']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UpdatePostScreen(
                                        postId: post['id']),
                              ),
                            ).then((_) {
                              // Tải lại bài đăng sau khi quay lại từ UpdatePostScreen
                              getUserId().then((userId) {
                                if (userId != null) {
                                  fetchPosts(userId); // Tải lại bài đăng của userId
                                }
                              });
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // Hiển thị hộp thoại xác nhận trước khi xóa
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text('Are you sure you want to delete this post?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false); // Người dùng hủy xóa
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true); // Người dùng xác nhận xóa
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                            // Nếu người dùng xác nhận xóa
                            if (confirmDelete) {
                              // Lấy userId từ SharedPreferences
                              String? userId = await getUserId();

                              if (userId != null) {
                                try {
                                  final response = await http.delete(
                                    Uri.parse('${Config_URL.baseUrl}api/Post/${post['id']}?userId=$userId'),
                                  );

                                  if (response.statusCode == 204) {
                                    // Thông báo xóa bài thành công
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Post deleted successfully!')),
                                    );
                                    fetchPosts(userId); // Tải lại danh sách bài đăng
                                  } else {
                                    // Thông báo lỗi khi xóa bài
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Failed to delete post')),
                                    );
                                  }
                                } catch (e) {
                                  // Thông báo lỗi xảy ra khi gọi API
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error occurred: $e')),
                                  );
                                }
                              } else {
                                // Thông báo không tìm thấy userId
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User ID not found. Please login again.')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Điều hướng tới trang tạo bài viết
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          ).then((_) {
            // Refresh danh sách bài đăng sau khi tạo xong
            getUserId().then((userId) {
              if (userId != null) {
                fetchPosts(userId);
              }
            });
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Create Post', // Tooltip hiện khi người dùng nhấn giữ
      ),
    );
  }
}
