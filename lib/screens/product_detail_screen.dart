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
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      //   backgroundColor: Theme.of(context).primaryColor,
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          //A Sliver in Flutter is basically a scrollable area fragment — a piece of a custom scrollable UI.
          // Think of them as "scrollable building blocks" that let you build highly custom scrolling effects.
          // Instead of a plain ListView (which has a fixed structure: one big scrolling column), slivers let you combine different scrolling sections that behave differently.
          SliverAppBar(
            backgroundColor: Theme.of(context).primaryColor,
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id!,
                child: Image.network(loadedProduct.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 10),
              Text(
                '\$${loadedProduct.price}',
                style: TextStyle(color: Colors.grey, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              SizedBox(height: 800),
            ]),
          ),
        ],
      ),
    );
  }
}
// What is a “listener” in Provider?

// A widget becomes a listener when it uses:

// Provider.of<Products>(context) without listen: false

// Or a Consumer<Products>

// Or a Selector<Products, ...>
