import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
final bool _showFavoritesOnly;
ProductsGrid(this._showFavoritesOnly);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    //👉 productsData is a reference to your Products provider instance.
    final products =_showFavoritesOnly? productsData.favoriteItems:productsData.items;
    //👉 products becomes a List<Product> that your widget can use to build the grid.

    //Provider.of<Products>(context) = “Get me the shared Products data from the provider.”
    // productsData.items = “Access the list of products inside that provider.”
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        // Each ProductItem now gets its product via provider.
        // products[index] itself is now a ChangeNotifier
        // Each Product manages its own state (isFavorite).
        // Each ProductItem listens only to its product.
        value: products[index],
        child: ProductItem(), //Inside ProductItem:
        // final product = Provider.of<Product>(context);
        // Now product is reactive.
        // If product.isFavorite changes, only this widget rebuilds.
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}

//Centralized state → all screens can access the same product list.
// Reactivity → if you later add/remove/change a product in Products and call notifyListeners(),
// every widget that used Provider.of<Products>(context) will rebuild automatically with the new data.
