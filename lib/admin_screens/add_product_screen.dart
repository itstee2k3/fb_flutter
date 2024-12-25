import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import '../models/product_post.dart'; // Đảm bảo import đúng model

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();

  // Add product
  Future<void> addProduct() async {
    try {
      final newProduct = productPost(
        id: null, // ID sẽ được tạo tự động
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        image: _imageController.text,
        description: _descriptionController.text,
      );

      final response = await http.post(
        Uri.parse('${Config_URL.baseUrl}api/ProductApi'),
        headers: {'Content-Type': 'application/json'}, // Đảm bảo định dạng JSON
        body: jsonEncode(newProduct.toJson()), // Chuyển đổi dữ liệu thành JSON
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully.')),
        );

        Navigator.pop(context, true); // Quay lại và báo thành công
      } else {
        throw Exception('Failed to add product');
      }
    } catch (error) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
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
              onPressed: addProduct,
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
