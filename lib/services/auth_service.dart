import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config_url.dart';

class AuthService {
  // Đường dẫn đến API login
  String get apiUrl => "${Config_URL.baseUrl}login";

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Kiểm tra xem dữ liệu có hợp lệ không
        if (data == null) {
          return {"success": false, "message": "Empty response from server"};
        }

        bool status = data['status'] ?? false; // Kiểm tra nếu không có status, mặc định là false
        if (!status) {
          return {"success": false, "message": data['message'] ?? 'Login failed'};
        }

        // Lấy token từ API trả về
        String? token = data['token']; // Sử dụng String? để nhận giá trị null

        // Kiểm tra token có null không
        if (token == null || token.isEmpty) {
          return {"success": false, "message": "Token is null or empty"};
        }

        // Kiểm tra tính hợp lệ của token
        if (JwtDecoder.isExpired(token)) {
          return {"success": false, "message": "Invalid or expired token"};
        }

        // Giải mã token để lấy các thông tin đăng nhập
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        // Lấy userId và role từ token
        String userId = decodedToken['userId'] ?? ""; // Kiểm tra null trước khi sử dụng
        String role = decodedToken['role'] ?? "User"; // Lấy role từ token, mặc định là "User"

        // Kiểm tra nếu userId null hoặc rỗng
        if (userId.isEmpty) {
          return {"success": false, "message": "User ID is empty"};
        }

        // Lưu token, userId và role vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('userId', userId);
        await prefs.setString('role', role);

        return {
          "success": true,
          "token": token,
          "userId": userId,
          "role": role,  // Trả về role trong kết quả
          "decodedToken": decodedToken,
        };
      } else {
        // Nếu mã trạng thái không phải 200, trả về lỗi đăng nhập
        return {"success": false, "message": "Failed to login: ${response.statusCode}"};
      }
    } catch (e) {
      // Xử lý lỗi mạng hoặc lỗi phân tích
      return {"success": false, "message": "Network error: $e"};
    }
  }
}
