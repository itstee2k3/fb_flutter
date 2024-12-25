// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/product_post.dart'; // Đường dẫn tới model productPost
//
// class ProductService {
//   Future<List<productPost>> fetchProducts() async {
//     final response = await http.get(Uri.parse('http://localhost:5019/api/ProductApi'));
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((json) => productPost.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load products');
//     }
//   }
// }
