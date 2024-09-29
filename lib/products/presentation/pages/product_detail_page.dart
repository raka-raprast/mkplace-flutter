import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:mkplace/core/models/product.dart';

Future<List<ProductModel>> loadProducts() async {
  // Load the JSON file
  final String response =
      await rootBundle.loadString('lib/assets/fake_data.json');
  // Parse the JSON data
  final List<dynamic> data = jsonDecode(response);
  // Convert to List<ProductModel>
  return data.map((json) => ProductModel.fromJson(json)).toList();
}

Future<ProductModel?> loadProduct(String id) async {
  final products = await loadProducts();
  final product = products.where((element) => element.id == id);
  if (product.isNotEmpty) {
    return product.first;
  } else {
    return null;
  }
}

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});
  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductModel? product;
  int qty = 0;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      product = await loadProduct(widget.productId);
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Center(child: Text("Product not available"));
    }
    return Container(
      color: Colors.white,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedNetworkImage(
                          imageUrl: product?.imageUrl ?? "",
                          fit: BoxFit.cover,
                          height: 400,
                          width: double.infinity,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error,
                            size: 40,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product?.name ?? "-",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${product?.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Stock: ${(product?.stock ?? 0) > 0 ? product?.stock : "Out of Stock"}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: (product?.stock ?? 0) > 0
                                      ? Colors.black
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Category: ${product?.category}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Description:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product?.description ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Seller: ${product?.seller}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(999)),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 24,
                        )),
                  ))
                ],
              ),
            ),
            SafeArea(
                child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text("Qty"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                              onTap: () {
                                if (qty > 0) {
                                  setState(() {
                                    qty -= 1;
                                  });
                                }
                              },
                              child: const Icon(Icons.arrow_back_ios_new)),
                          Text(
                            qty.toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                          InkWell(
                            onTap: () {
                              if (qty < 99) {
                                setState(() {
                                  qty += 1;
                                });
                              }
                            },
                            child: const RotatedBox(
                                quarterTurns: 2,
                                child: Icon(Icons.arrow_back_ios_new)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: qty > 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.inversePrimary,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Center(
                        child: Text(
                      "Add To Cart",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ))),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
