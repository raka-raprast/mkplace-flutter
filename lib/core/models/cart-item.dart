import 'package:mkplace/core/models/product.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}
