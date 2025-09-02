import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;
  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
      'https://shop-app-30e37-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken',
    );

    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
      'https://shop-app-30e37-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken',
    );
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'id': DateTime.now().toString(),
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map(
              (cp) => {
                'id': cp.id,
                'title': cp.title,
                'quantity': cp.quantity,
                'price': cp.price,
              },
            )
            .toList(),
      }),
    );
    _orders.insert(
      //putIfAbsent(...) only works with maps not lists thats why we used insert
      //Orders are a list of independent entries, so duplicates are fine — each order is unique.
      0,
      OrderItem(
        //..cartProducts is a list of CartItems that the user is purchasing in this order.
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: DateTime.now(),
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}

// So the reason the most recent order shows last is just because add() appends to the end, whereas insert(0, ...) places it at the start
