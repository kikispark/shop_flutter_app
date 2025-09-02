import 'package:flutter/material.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  // ProductItem(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return GridTile(
      footer: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, Product, child) => IconButton(
              //child: <-- this widget never rebuilds
              // Use child to optimize performance in lists/grids with many items.
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () {
                product.toggleFavoriteStatus(authData.token, authData.userId);
              },
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: Text(product.title, textAlign: TextAlign.center),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product.id!, product.price, product.title!);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added item to cart!'),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(product.id!);
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      child: GestureDetector(
        //GestureDetector is a widget that lets you listen for user gestures (like taps, double taps, swipes, long presses, drags, etc.) on its child
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(ProductDetailScreen.routeName, arguments: product.id);
        },

        child: Image.network(product.imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
//consumer:Rebuilds only the widgets inside its builder when the provider calls notifyListeners().
// Provider.of rebuilds if listening
// Only the builder function inside Consumer rebuilds

// Provider.of<T>(context, listen: false)

// Purpose: You just want to get access to the provider to call methods or read values once.

// Rebuild behavior: Does not rebuild when the provider calls notifyListeners().

// Use case: Buttons or actions that trigger changes but don’t need to display dynamic provider data.

// Consumer<T>

// What it does: Builds only the widget inside its builder whenever the provider calls notifyListeners().

// Does it rebuild the parent widget? ❌ No, only the builder.
// listen: false → “I want the provider, but I don’t care about updates.”

// Consumer → “I want the provider and I want to rebuild only this part when it updates.”
