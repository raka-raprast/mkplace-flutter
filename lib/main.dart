import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mkplace/products/presentation/pages/cart_list.dart';
import 'package:mkplace/products/presentation/pages/list_product.dart';
import 'package:mkplace/products/presentation/pages/product_detail_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  WebViewController? controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse("http://192.168.88.21:3000?hideBar=true"))
      ..addJavaScriptChannel("Flutter", onMessageReceived: (message) {
        String msg = message.message.replaceAll('"', '');
        if (msg == "viewMore") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ListProductPage(
                isViewMore: true,
              ),
            ),
          );
        } else {
          String productId = msg;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(productId: productId),
            ),
          );
        }
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true; // Start loading
            });
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false; // Stop loading
            });
          },
        ),
      );
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ListProductPage(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: const Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 8),
                      Expanded(
                        child: IgnorePointer(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartListPage(),
                  ),
                );
              },
              child: const Icon(
                CupertinoIcons.cart_fill,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Stack(
            children: [
              if (controller != null && !_isLoading)
                WebViewWidget(controller: controller!),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ), // Home tab (WebView)
          const Center(child: Text('Profile Page')), // Profile tab
        ],
      ),
      bottomNavigationBar: Material(
        color: Colors.white,
        shadowColor: Colors.grey,
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.black,
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
