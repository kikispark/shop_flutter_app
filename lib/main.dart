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
          //===>A special Provider that makes a ChangeNotifier available to all widgets below it in the widget tree and automatically listens for changes.
          create: (_) => Auth(),
        ), //creates the Auth() instance only once when the provider is first initialized. During hot reload, the same instance is preserved, maintaining your authentication state.
        ChangeNotifierProxyProvider<Auth, Products>(
          //Products depends on Auth → it needs the token/userId to work.
          create: (_) => Products(null, null, []),
          // Called once when the app starts.
          // It creates an initial instance of Products.
          update: (ctx, auth, previousProducts) => Products(
            //Called every time Auth changes (e.g., login/logout, token refresh).
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
            //previousProducts = the old Products instance (so you don’t lose your data).
            //make sure we don’t lose existing data when updating
            // This line ensures that Products keeps its items even when Auth changes
          ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ), //Cart doesn’t depend on Auth → it can exist and be used before login.
        // initial instance ,Cart already exists, keeps the items the user added before login.
        // Later, when checking out, you may combine Cart + Auth to send data to a server.
        // Think of a shopping bag on an e-commerce website:
        // You can start adding items as a guest (before login).
        // Later, you log in, and your bag might sync with your account.
        ChangeNotifierProxyProvider<Auth, Orders>(
          //When a provider depends on another provide
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
        // consumer: If Auth changes (user logs in or out), we need MaterialApp to rebuild with the correct home screen.
        // Without Consumer, the MaterialApp would not rebuild automatically, and the screen wouldn’t update when auth.isAuth changes.
        builder: (ctx, auth, _) => MaterialApp(
          //builder:called ==> a consumer builder function
          //in this arguments of builder the '_' is means child → an optional widget that does not rebuild when the provider changes.
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.purple,
            ).copyWith(primary: Colors.purple.shade300),
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  //A Future in Flutter = a value that will be available later (async).
                  //FutureBuilder:it listens to the Future and rebuilds the widget when the Future completes.
                  // tryAutoLogin() is an async method that checks persistent storage (SharedPreferences) for stored login data.
                  future: auth.tryAutoLogin(),
                  builder:
                      (
                        ctx,
                        authResultSnapshot,
                      ) => //second parameter is always an AsyncSnapshot object.,the result of the auth future
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


//difference between provider and changenotifierprovider:
// ChangeNotifierProvider = creates + provides + manages lifecycle of Auth

// Provider.of(context) = reads Auth and rebuilds this widget when notifyListeners() is called

// Products / Orders → depend on Auth (needs token & userId) → ChangeNotifierProxyProvider.

// AsyncSnapshot contains information about:

// connectionState → whether the Future is waiting, active, done, or none.

// data → the result value of the Future (if completed successfully).

// error → any error if the Future failed.





// ConnectionState.waiting → means: Future is still in progress.

// ConnectionState.done → means: Future has completed (successfully or with error).

// ConnectionState.none → no Future was provided.

// ConnectionState.active → (used in streams, less in futures).



// SharedPreferences vs in-memory token

// SharedPreferences = persistent storage on device.

// _token = runtime memory variable in your Auth class.

// When the app launches:

// _token = null

// auth.isAuth = false

// SharedPreferences may contain a stored token, but the app hasn’t loaded it yet.

// This is why auth.isAuth is initially false even if the user is logged in from a previous session.