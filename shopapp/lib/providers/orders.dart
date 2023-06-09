import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopapp/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  final String _authToken;
  final String userId;
  Orders(this._authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    // final url = Uri.https(
    //     'flutter-shopapp-4cd88-default-rtdb.firebaseio.com', 'orders.json');
    Uri url = Uri.parse(
        'https://flutter-shopapp-4cd88-default-rtdb.firebaseio.com/orders/$userId.json?auth=$_authToken');
    try {
      final response = await http.get(url);
      if (json.decode(response.body) == null) {
        return;
      }

      final List<OrderItem> loadedOrders = [];

      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                      id: item['id'],
                      title: item['title'],
                      quantity: item['quantity'],
                      price: item['price']),
                )
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime']),
          ),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    // final url = Uri.https(
    //     'flutter-shopapp-4cd88-default-rtdb.firebaseio.com', 'orders.json');
    Uri url = Uri.parse(
        'https://flutter-shopapp-4cd88-default-rtdb.firebaseio.com/orders/$userId.json?auth=$_authToken');
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': cartProducts
                .map((e) => {
                      'id': e.id,
                      'price': e.price,
                      'title': e.title,
                      'quantity': e.quantity,
                    })
                .toList(),
            'dateTime': timeStamp.toIso8601String()
          }));

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp,
        ),
      );
    } catch (e) {
      print(e);
      throw e;
    }

    notifyListeners();
  }
}
