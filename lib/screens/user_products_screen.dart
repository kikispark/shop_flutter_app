import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  //So async/await in fetchAndSetProducts() ensures the request finishes inside that function, while async/await in _refreshProducts ensures the UI code that calls it also waits before proceeding.
  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(
      context,
      listen: false,
    ).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilding ...");
    // final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Products',
          style: TextStyle(
            color: Colors.black87,
            // fontWeight: FontWeight.bold, // optional styling
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        //This runs once when the screen is first built.
        //FutureBuilder does not re-run the future on every rebuild—it caches the old future.
        future: _refreshProducts(
          context,
        ), //The FutureBuilder will run _refreshProducts(context) — fetching the latest product data.
        builder:
            (
              ctx,
              snapshot,
            ) => //holds the current state of the future (loading, data, error, etc.).
            snapshot.connectionState == ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                //manual refresh triggered by the user
                //It adds the common “pull-to-refresh”
                onRefresh: () => _refreshProducts(context),
                child: Consumer<Products>(
                  builder: (ctx, productsData, _) => Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: productsData.items.length,
                      itemBuilder: (_, i) => Column(
                        children: [
                          UserProductItem(
                            productsData.items[i].id!,
                            productsData.items[i].title,
                            productsData.items[i].imageUrl,
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
