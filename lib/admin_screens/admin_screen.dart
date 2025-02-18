import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Đảm bảo đã import SharedPreferences
import 'package:flutter_bui_xuan_thang/screens/login_screen.dart';

import '../config/config_url.dart';
import '../models/cart_post.dart'; // Đảm bảo import màn hình login của bạn
import '../models/product_post.dart';
import 'edit_product_screen.dart'; // Import your EditProductScreen
import 'add_product_screen.dart'; // Import your AddProductScreen
import 'package:intl/intl.dart'; // Import intl

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<List<Product>> products;

  @override
  void initState() {
    super.initState();
    products = fetchProducts();
  }

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(
        Uri.parse('${Config_URL.baseUrl}api/ProductApi'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        'ngrok-skip-browser-warning': 'true'
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Delete product with confirmation
  Future<void> confirmDeleteProduct(BuildContext context, int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Người dùng chọn "No"
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Người dùng chọn "Yes"
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final response = await http.delete(Uri.parse('${Config_URL.baseUrl}api/ProductApi/$id'));
        if (response.statusCode == 204) {
          setState(() {
            products = fetchProducts(); // Làm mới danh sách sản phẩm
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product deleted successfully.")),
          );
        } else {
          throw Exception("Failed to delete product.");
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      }
    }
  }

  // Logout function
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');  // Remove the token
    await prefs.remove('userId');     // Remove the userId

    // Navigate back to the Login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout(context);  // Gọi hàm đăng xuất
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                final formattedPrice = NumberFormat('#,##0', 'vi_VN').format(product.price);

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: product.image != null && product.image!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        product.image!,
                        width: 50, // Đặt kích thước cho ảnh
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, size: 50);
                        },
                      ),
                    )
                        : const Icon(Icons.image_not_supported, size: 50), // Icon khi không có ảnh
                    title: Text(product.name),
                    subtitle: Text(
                        // '${product.description}\nPrice: \$${product.price}'
                      '${product.description}\nGiá: $formattedPrice VNĐ',

                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProductScreen(product: productPost.fromJson(product.toJson())),
                              ),
                            );

                            if (result == true) {
                              setState(() {
                                products = fetchProducts(); // Làm mới danh sách sản phẩm
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            confirmDeleteProduct(context, product.id);
                          },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );

          if (result == true) {
            setState(() {
              products = fetchProducts(); // Làm mới danh sách sản phẩm
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
