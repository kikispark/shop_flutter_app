import 'package:flutter/material.dart';
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
                product.toggleFavoriteStatus();
              },
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: Text(product.title, textAlign: TextAlign.center),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {},
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      child: GestureDetector(
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