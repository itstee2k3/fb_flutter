import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import '../models/product_post.dart';

class EditProductScreen extends StatefulWidget {
  final productPost product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _imageController = TextEditingController(text: widget.product.image);
  }

  // Update product
  Future<void> updateProduct() async {
    final updatedProduct = productPost(
      id: widget.product.id,
      name: _nameController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      image: _imageController.text,
      description: _descriptionController.text,
    );

    try {
      final response = await http.put(
        Uri.parse('${Config_URL.baseUrl}api/ProductApi/${widget.product.id}'),
        headers: {'Content-Type': 'application/json'}, // Đảm bảo định dạng JSON
        body: jsonEncode(updatedProduct.toJson()), // Gửi dữ liệu dưới dạng JSON
      );

      if (response.statusCode == 204) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );

        // Quay lại trang chính
        Navigator.pop(context, true); // Trả về kết quả thành công
      } else {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product: ${response.statusCode}')),
        );
      }
    } catch (error) {
      // Xử lý lỗi mạng hoặc lỗi khác
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProduct,
              child: const Text('Update Product'),
            ),
          ],
        ),
      ),
    );
  }
}
