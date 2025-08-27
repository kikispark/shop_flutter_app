import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String id;
  // final String title;
  // final double price;
  // ProductDetailScreen(this.id, this.title, this.price);

  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    // listen:false:====>widget just reads data once and ignores updates.
    // That’s okay, because when you navigate to the detail screen, you’ll already pass the correct id of the clicked product.
    // It doesn’t matter if it was added 5 minutes ago — as long as it’s in the provider’s _items, findById will get it.
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(child: Text('from productdetails')),
    );
  }
}
// What is a “listener” in Provider?

// A widget becomes a listener when it uses:

// Provider.of<Products>(context) without listen: false

// Or a Consumer<Products>

// Or a Selector<Products, ...>
