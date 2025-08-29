import 'package:flutter/foundation.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.insert(
      //putIfAbsent(...) only works with maps not lists thats why we used insert
      //Orders are a list of independent entries, so duplicates are fine — each order is unique.
      0,
      OrderItem(
        //..cartProducts is a list of CartItems that the user is purchasing in this order.
        id: DateTime.now().toString(),
        amount: total,
        dateTime: DateTime.now(),
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}

// So the reason the most recent order shows last is just because add() appends to the end, whereas insert(0, ...) places it at the start
