class productPost {
  productPost({
    this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  final int? id; // Không bắt buộc (nullable)
  final String? name; // Tên sản phẩm
  final double? price; // Giá sản phẩm
  final String? image; // Đường dẫn ảnh
  final String? description; // Mô tả sản phẩm

  // Factory từ JSON
  factory productPost.fromJson(Map<String, dynamic> json) {
    return productPost(
      id: json["id"],
      name: json["name"],
      price: (json["price"] as num?)?.toDouble(), // Chuyển đổi kiểu số nếu cần
      image: json["image"],
      description: json["description"],
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data["id"] = id; // Chỉ thêm `id` nếu không null
    if (name != null) data["name"] = name;
    if (price != null) data["price"] = price;
    if (image != null) data["image"] = image;
    if (description != null) data["description"] = description;
    return data;
  }
}
