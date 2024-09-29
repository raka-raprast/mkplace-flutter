// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mkplace/core/models/cart-item.dart';
import 'package:mkplace/core/models/product.dart';
import 'package:mkplace/shared/components/checkbox.dart'; // For loading assets

class CartListPage extends StatefulWidget {
  const CartListPage({super.key});

  @override
  _CartListPageState createState() => _CartListPageState();
}

class _CartListPageState extends State<CartListPage> {
  List<CartItem> cartItems = [];
  List<bool> selectedItems = []; // To track checkbox states

  @override
  void initState() {
    super.initState();
    loadFakeData(); // Load data when the page initializes
  }

  // Method to load and parse fake_data.json
  Future<void> loadFakeData() async {
    final String response =
        await rootBundle.loadString('lib/assets/fake_data.json');
    final List<dynamic> data = jsonDecode(response);

    // Parse the data and convert it to a list of ProductModel
    List<ProductModel> products =
        data.map((json) => ProductModel.fromJson(json)).toList();

    // Randomly select 4 items from the list
    final random = Random();
    List<ProductModel> randomProducts =
        List.generate(4, (index) => products[random.nextInt(products.length)]);

    // Convert the random products to CartItems with default quantity of 1
    setState(() {
      cartItems = randomProducts
          .map((product) => CartItem(product: product, quantity: 1))
          .toList();
      selectedItems = List.generate(cartItems.length,
          (index) => false); // Initialize all checkboxes to false
    });
  }

  // Method to calculate total price based on selected items
  double calculateTotalPrice() {
    double total = 0;
    for (int i = 0; i < cartItems.length; i++) {
      if (selectedItems[i]) {
        total += cartItems[i].product.price * cartItems[i].quantity;
      }
    }
    return total;
  }

  // Method to check if at least one item is selected
  bool isCheckoutDisabled() {
    return !selectedItems.contains(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Checkout'),
      ),
      body: cartItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      CartItem cartItem = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        child: ListTile(
                          leading: IntrinsicWidth(
                            child: Row(
                              children: [
                                CustomCheckbox(
                                  isChecked: selectedItems[index],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      selectedItems[index] = value!;
                                    });
                                  },
                                ),
                                Image.network(cartItem.product.imageUrl,
                                    width: 50, height: 50),
                              ],
                            ),
                          ),
                          title: Text(
                            cartItem.product.name,
                            maxLines: 2,
                          ),
                          subtitle: Text('Price: \$${cartItem.product.price}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (cartItem.quantity > 1) {
                                            cartItem.quantity--;
                                          }
                                        });
                                      },
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: Icon(Icons.remove),
                                      )),
                                  Text(
                                    '${cartItem.quantity}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (cartItem.quantity <
                                              cartItem.product.stock) {
                                            cartItem.quantity++;
                                          }
                                        });
                                      },
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: const Icon(Icons.add),
                                      )),
                                ],
                              ),
                              Text(
                                  'Total: \$${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: \$${calculateTotalPrice().toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: isCheckoutDisabled()
                            ? null
                            : () {
                                // Handle checkout logic for selected items
                                List<CartItem> selectedCartItems = [];
                                for (int i = 0; i < cartItems.length; i++) {
                                  if (selectedItems[i]) {
                                    selectedCartItems.add(cartItems[i]);
                                  }
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Checkout Successful for ${selectedCartItems.length} items!')),
                                );
                              },
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
