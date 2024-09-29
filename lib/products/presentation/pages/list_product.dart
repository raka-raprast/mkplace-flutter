import 'package:flutter/material.dart';
import 'package:mkplace/products/presentation/pages/product_detail_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ListProductPage extends StatefulWidget {
  const ListProductPage({super.key, this.isViewMore = false});
  final bool isViewMore;
  @override
  State<ListProductPage> createState() => _ListProductPageState();
}

class _ListProductPageState extends State<ListProductPage> {
  bool _isLoading = true;
  WebViewController? controller;
  FocusNode focusNode = FocusNode();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    if (!widget.isViewMore) {
      focusNode.requestFocus();
    }
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
          Uri.parse("http://192.168.88.21:3000/product/search?hideBar=true"))
      ..addJavaScriptChannel("Flutter", onMessageReceived: (message) {
        String productId = message.message.replaceAll('"', '');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: productId),
          ),
        );
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
    super.initState();
  }

  void _sendSearchQuery() {
    if (controller != null && searchController.text.isNotEmpty) {
      // Construct the new URL with the search query
      final searchQuery = searchController.text;
      final newUrl =
          'http://192.168.88.21:3000/product/search?query=$searchQuery&hideBar=true';

      // Load the new URL into the WebView
      controller!.loadRequest(Uri.parse(newUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        readOnly: _isLoading,
                        focusNode: focusNode,
                        onSubmitted: (_) =>
                            _sendSearchQuery(), // Send query on Enter
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _sendSearchQuery, // Send query on button press
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (controller != null && !_isLoading)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (searchController.text.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 24, top: 12),
                    child: Text(
                      "Search Result",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                Expanded(child: WebViewWidget(controller: controller!)),
              ],
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
