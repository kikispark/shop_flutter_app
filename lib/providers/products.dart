import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  //is a Flutter class that provides a way to manage state
  // Call notifyListeners() when that data changes.
  // Any widget listening to it will automatically rebuild.
  List<Product> _items = [];
  // So anywhere you call productsData.items, you’ll get a list like:
  // [Product(id: 'p1', title: 'Red Shirt', ...), Product(id: 'p2', ...)]

  // var _showFavoritesOnly = false;


  final String? authToken;  
  final String? userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    //returning a copy ([..._items]),
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }
  // void showFavoritesOnly(){
  //   _showFavoritesOnly=true;
  //   notifyListeners();
  // }
  // void showAll(){
  //   _showFavoritesOnly=false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    //=>optional parameter
    //this function return a future like a promise in JS
    final queryParams = {
      'auth':
          authToken, //they filled at object creation we will have the authToken and userId
      if (filterByUser)
        'orderBy':
            '"creatorId"', //tells Firebase which field to use for sorting/filtering exp: 3&orderBy="n"&equalTo="user123"
      if (filterByUser)
        'equalTo': '"$userId"', //tells Firebase which value must match
    };

    final url = Uri.https(
      //uri:how to access a resource (Uniform Resource Identifier)
      'shop-app-30e37-default-rtdb.firebaseio.com',
      '/products.json',
      queryParams,
    );

    try {
      final response = await http.get(
        url,
      ); //Uses the http package to send a GET request to Firebase.

      final extractedData = json.decode(
        response.body,
      ); //Parses the JSON string from the response into a Dart object (usually a Map<String, dynamic>).
      if (extractedData == null || extractedData is! Map<String, dynamic>) {
        return; // nothing found or permission denied
      }

      final favUrl = Uri.https(
        //Builds a URL to fetch favorites for the current user.
        'shop-app-30e37-default-rtdb.firebaseio.com',
        '/userFavorites/$userId.json',
        {'auth': authToken},
      );

      final favoriteResponse = await http.get(favUrl);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        //prodId:In Firebase’s Realtime Database, you don’t see a “prodId” field inside the data, because the ID is the key in the tree structure so it generates automatically .
        loadedProducts.add(
          //So we convert each map(extractedData) into a Product object and add it to loadedProducts.
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite: favoriteData == null
                ? false
                : (favoriteData[prodId] ?? false), //this return true or false
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
      'https://shop-app-30e37-default-rtdb.firebaseio.com/products.json?auth=$authToken',
    );
    try {
      final response = await http.post(
        url,
        body: json.encode({
          //converts a Dart object ====> JSON string
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere(
      (prod) => prod.id == id,
    ); //Returns the index in the list, or -1 if not found.
    if (prodIndex >= 0) {
      final url = Uri.parse(
        'https://shop-app-30e37-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken',
      );
      await http.patch(
        //we use patch here and dont put because Only the fields in your body are updated; others stay untouched
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
      'https://shop-app-30e37-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken',
    );

    // Remove locally first (optional: or after successful HTTP call)
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw HttpException('Failed to delete product.');
    }
  }

  //  Future<void> deleteProduct(String id) async {
  //   final url = 'https://flutter-update.firebaseio.com/products/$id.json';
  //   final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
  //   var existingProduct = _items[existingProductIndex];
  //   _items.removeAt(existingProductIndex);
  //   notifyListeners();
  //   final response = await http.delete(url);
  //   if (response.statusCode >= 400) {
  //     _items.insert(existingProductIndex, existingProduct);
  //     notifyListeners();
  //     throw HttpException('Could not delete product.');
  //   }
  //   existingProduct = null;
  // }
}

  //Products extends ChangeNotifier, which gives us the notifyListeners() method. Any widget listening will rebuild when data changes.
//  example of extractedData  : {
//   "-N1abc": {
//     "title": "Running Shoes",
//     "description": "Comfortable shoes",
//     "price": 59.99,
//     "imageUrl": "https://example.com/shoes.jpg",
//     "creatorId": "user123"
//   },
//   "-N1def": {
//     "title": "Hat",
//     "description": "Cool hat",
//     "price": 19.99,
//     "imageUrl": "https://example.com/hat.jpg",
//     "creatorId": "user456"
//   }
// }