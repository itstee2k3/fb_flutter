class CartPost {
  final String userId;
  final int productId;
  final int quantity;
  final Product? product; // Thêm thông tin sản phẩm

  CartPost({
    required this.userId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  factory CartPost.fromJson(Map<String, dynamic> json) {
    return CartPost(
      userId: json["userId"],
      productId: json["productId"],
      quantity: json["quantity"],
      product: json["product"] != null
          ? Product.fromJson(json["product"]) // Ánh xạ trường product
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "productId": productId,
    "quantity": quantity,
    "product": product?.toJson(), // Serialize product nếu tồn tại
  };
}

class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      name: json["name"],
      price: json["price"].toDouble(),
      image: json["image"],
      description: json["description"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "image": image,
    "description": description,
  };
}
