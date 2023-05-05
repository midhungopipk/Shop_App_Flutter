import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  var _showFavouritesOnly = false;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((product) => product.favourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.https(
        'flutter-shopapp-4cd88-default-rtdb.firebaseio.com', 'products.json');

    try {
      final response = await http.get(url);
      if (json.decode(response.body) == null) {
        return;
      }
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          favourite: prodData['favourite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      print(e);
      // throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
        'flutter-shopapp-4cd88-default-rtdb.firebaseio.com', 'products.json');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            "imageUrl": product.imageUrl,
            "price": product.price,
            "favourite": product.favourite
          }));

      print(json.decode(response.body));
      final newProduct = Product(
          // id: DateTime.now().toString(),
          id: json.decode(response.body)['name'],
          title: product.title,
          price: product.price,
          description: product.description,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    final url = Uri.https('flutter-shopapp-4cd88-default-rtdb.firebaseio.com',
        'products/$id.json');
    http.patch(url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          "imageUrl": newProduct.imageUrl,
          "price": newProduct.price,
          "favourite": newProduct.favourite
        }));
    _items[prodIndex] = newProduct;

    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https('flutter-shopapp-4cd88-default-rtdb.firebaseio.com',
        'products/$id.json');
    final existingProductId = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductId];
    _items.removeAt(existingProductId);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductId, existingProduct);
      //if deleting failed the items will readd to the list
      notifyListeners();
      throw HttpException('Could not delete product');
      //this is done because http.delete will not go to catch error if the delete request failed
    }

    existingProduct = null;
  }
}
