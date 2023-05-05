import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool favourite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.favourite = false});

  Future<void> toggleFavourite() async {
    bool oldStatus = favourite;
    favourite = !favourite;
    notifyListeners();
    final url = Uri.https('flutter-shopapp-4cd88-default-rtdb.firebaseio.com',
        'products/$id.json');
    try {
      final response =
          await http.patch(url, body: json.encode({"favourite": favourite}));
      if (response.statusCode >= 400) {
        favourite = oldStatus;
        notifyListeners();
      }
    } catch (e) {
      favourite = oldStatus;
      notifyListeners();
    }
  }
}
