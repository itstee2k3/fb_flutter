import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import '../models/cart_post.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Lấy userId từ SharedPreferences
Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId'); // Trả về userId đã lưu
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartPost> _cartItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Lấy giỏ hàng từ API
  Future<void> fetchCartItems() async {
    final userId = await getUserId();

    if (userId == null) {
      setState(() {
        _errorMessage = 'User is not logged in';
        _isLoading = false;
      });
      return;
    }

    final String baseUrl = '${Config_URL.baseUrl}api/CartApi/user/$userId';

    try {
      final response = await http.get(
          Uri.parse(baseUrl),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List) {
          // If the response is a list
          setState(() {
            _cartItems = responseData.map((item) => CartPost.fromJson(item)).toList();
            _isLoading = false;
          });
        } else if (responseData is Map) {
          // If the response is a Map (e.g., error message or other data)
          setState(() {
            _errorMessage = responseData['message'] ?? 'Failed to load cart items';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load cart items';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // Hàm xóa sản phẩm khỏi giỏ hàng
  void removeFromCart(int productId) async {
    // Lấy userId từ SharedPreferences
    final userId = await getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not logged in')),
      );
      return;
    }

    final String apiUrl =
        '${Config_URL.baseUrl}api/CartApi/user/$userId/product/$productId';

    try {
      final response = await http.delete(Uri.parse(apiUrl));
      if (response.statusCode == 204) {
        setState(() {
          _cartItems.removeWhere((item) => item.productId == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product removed from cart')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove product from cart')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _cartItems.isEmpty
          ? const Center(child: Text('Chưa có sản phẩm trong giỏ hàng'))
          : ListView.builder(
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = _cartItems[index];
          final product = cartItem.product;

          return Dismissible(
            key: Key(cartItem.productId.toString()),
            direction: DismissDirection.endToStart, // Kéo sang phải
            onDismissed: (direction) {
              // Tạm ẩn sản phẩm
              setState(() {
                _cartItems.removeAt(index); // Ẩn sản phẩm tạm thời
              });

              // Hiển thị hộp thoại xác nhận xóa
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Delete'),
                    content: Text(
                        'Are you sure you want to remove ${product?.name}?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Nếu người dùng xác nhận xóa
                          removeFromCart(cartItem.productId);
                          Navigator.of(context).pop();
                        },
                        child: Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Nếu người dùng hủy bỏ, phục hồi lại sản phẩm
                          setState(() {
                            _cartItems.insert(index, cartItem); // Phục hồi sản phẩm
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text('No'),
                      ),
                    ],
                  );
                },
              );
            },
            background: Container(
              color: Colors.red, // Màu nền khi kéo
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: product != null
                    ? Image.network(
                  product.image,
                  width: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                )
                    : const Icon(Icons.shopping_cart),
                title: Text(product?.name ?? 'Unknown Product'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${cartItem.quantity} x ${product?.price ?? 0} VND'),
                    if (product?.description != null)
                      Text(
                        product!.description,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}
