import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  // example:"p1": CartItem(id: "c1", title: "Red Shirt", quantity: 2, price: 29.99),
  // "p2": CartItem(id: "c2", title: "Blue Pants", quantity: 1, price: 59.99),
  //Returns a copy of the map using the spread operator (..._items) so external code can’t accidentally modify _items directly

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Notice: this is not the sum of quantities, but just how many product IDs are inside the cart.
  // Example: if you have 2 Red Shirts and 1 Blue Pants → itemCount = 2 (two types of products).
  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      //this return true or false if the product is already in the cart
      // change quantity...
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          //existingCartItem = the current value in _items[productId] (the old CartItem).
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1, //Same id, title, price
          // But quantity increased by 1.
        ),
      );
    } else {
      _items.putIfAbsent(
        //If the key already exists → does nothing.
        // If the key does not exist → it calls the function () => value and inserts that value with the key.
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners(); // // remove all items from the cart usually after the user places an order.
  }
}
