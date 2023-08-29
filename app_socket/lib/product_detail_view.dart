import 'dart:convert';

import 'package:app_socket/product_model.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({
    super.key,
    this.id,
  });

  final int? id;

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late WebSocketChannel channel;
  ProductModel? product;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getDetail();
  }

  @override
  void dispose() {
    super.dispose();

    channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Text('${product?.toJson()} 1'),
            if (isLoading)
              const LinearProgressIndicator()
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white),
                child: ListTile(
                  leading: SizedBox(
                    width: 48,
                    height: 48,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(product?.imagesData?[0].image ?? ''),
                    ),
                  ),
                  title: Text(product?.title ?? ''),
                  subtitle: Text(product?.categoryData?.title ?? ''),
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<void> getDetail() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse('ws://10.0.2.2:8000/ws/products/${widget.id}/');
    channel = WebSocketChannel.connect(url);

    channel.stream.listen((event) {
      final res = jsonDecode(event);
      final data = ProductModel.fromJson(res['data']);
      setState(() {
        isLoading = false;
        product = data;
      });
    });
  }
}
