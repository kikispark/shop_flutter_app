import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  //ChangeNotifier allows each individual product to notify listeners when its state changes.
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite; //Added isFavorite (a mutable property).

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus() {
    isFavorite = !isFavorite;
    notifyListeners(); //thats like setstate in the provider package
  }
}

//using changeNotifier here because for example Example: toggling a favorite doesn’t require rebuilding the entire product list, only that specific ProductItem
