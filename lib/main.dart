import 'package:flutter/material.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:provider/provider.dart';
import './screens/cart_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth-screen.dart';
import './screens//splash_screen.dart';
import './helpers/custom_route.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ), //reates the Auth() instance only once when the provider is first initialized. During hot reload, the same instance is preserved, maintaining your authentication state.
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(null, null, []), // initial instance
          update: (ctx, auth, previousProducts) => Products( 
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(null, null, []), // initial instance
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      // Creates and provides a ChangeNotifier object (like your Products class) to the widget tree.
      //That provider gives back the Products object you created (Products() instance).
      // Now your widget has access to the data  inside Products
      child: Consumer<Auth>( 
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo', 

          theme: ThemeData(
            primarySwatch: Colors.purple,   
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.purple,
            ).copyWith(secondary: Colors.deepOrange),
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(builders:{
              TargetPlatform.android:CustomPageTransitionBuilder(),
              TargetPlatform.iOS:CustomPageTransitionBuilder(),
            })
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                          ConnectionState.waiting
                      ? SplashScreen()
                      : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: ((ctx) => ProductDetailScreen()),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
//Top-level providers → create:
// Existing objects, especially in lists/grids → .value: