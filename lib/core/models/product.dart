class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String imageUrl;
  final String seller;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
    required this.seller,
  });

  // Factory method to create a ProductModel from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(), // Convert to double
      stock: json['stock'] as int,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      seller: json['seller'] as String,
    );
  }

  // Method to convert ProductModel to JSON (optional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'image_url': imageUrl,
      'seller': seller,
    };
  }
}
