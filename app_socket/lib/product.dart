import 'dart:convert';

import 'package:app_socket/product_detail_view.dart';
import 'package:app_socket/product_model.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  List<ProductModel> listProduct = <ProductModel>[];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    handShakeProductWs();
    // getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Product')),
      body: Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              if (isLoading)
                const LinearProgressIndicator()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProductDetailView(
                              id: listProduct[index].id,
                            ),
                          ));
                        },
                        child: Text(listProduct[index].title ?? ''));
                  },
                  separatorBuilder: (_, index) => const SizedBox(
                    height: 16,
                  ),
                  itemCount: listProduct.length,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> getProduct() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   final res = await Dio().get('http://10.0.2.2:8000/api/products/',
  //       options: Options(headers: {
  //         'Authorization': 'Token e892f4db9c488e51461514f57b27aaeb7cae549e'
  //       }));
  //   final data = (res.data['data'] as List)
  //       .map((e) => ProductModel.fromJson(e))
  //       .toList();
  //   setState(() {
  //     isLoading = false;
  //     listProduct = data;
  //   });
  // }

  Future<void> handShakeProductWs() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse('ws://10.0.2.2:8000/ws/products/');
    var channel = WebSocketChannel.connect(url);

    channel.stream.listen((event) {
      print("----------$event");
      final res = jsonDecode(event);
      final data =
          (res['data'] as List).map((e) => ProductModel.fromJson(e)).toList();
      setState(() {
        isLoading = false;
        listProduct = data;
      });
    });

    channel.sink.add(jsonEncode({'message': 'thanks for accept'}));
  }
}
