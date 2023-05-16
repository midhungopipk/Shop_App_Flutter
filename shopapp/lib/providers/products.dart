import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shopapp/providers/auth.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  var _showFavouritesOnly = false;

  final String _authToken;
  final String userId;

  Products(this._authToken, this.userId, this._items);
  // void recieveToken(String token, List<Product> item) {
  //   _authToken = token as String;
  //   _items = item;
  // }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((product) => product.favourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    // final url = Uri.https('flutter-shopapp-4cd88-default-rtdb.firebaseio.com',
    //     'products.json?auth=$_authToken');
    var filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://flutter-shopapp-4cd88-default-rtdb.firebaseio.com/products.json?auth=$_authToken&$filterString');
//&orderBy="creatorId"&equalTo="$userId" is the query used to filter the Products added by user. After adding creatorId for every products
//while adding a product
    try {
      final response = await http.get(url);
      if (json.decode(response.body) == null) {
        return;
      }

      url = Uri.parse(
          'https://flutter-shopapp-4cd88-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$_authToken');

      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);

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
          favourite: favouriteData == null
              ? false
              : favouriteData[prodId] ??
                  false, // "??" checks a value is null or not
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
    // final url = Uri.https(
    //     'flutter-shopapp-4cd88-default-rtdb.firebaseio.com', 'products.json');
    Uri url = Uri.parse(
        'https://flutter-shopapp-4cd88-default-rtdb.firebaseio.com/products.json?auth=$_authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            "imageUrl": product.imageUrl,
            "price": product.price,
            // "favourite": product.favourite
            "creatorId": userId
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
    // final url = Uri.https('flutter-shopapp-4cd88-default-rtdb.firebaseio.com',
    //     'products/$id.json');
    Uri url = Uri.parse(
        'https://flutter-shopapp-4cd88-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken');
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
    // final url = Uri.https('flutter-shopapp-4cd88-default-rtdb.firebaseio.com',
    //     'products/$id.json');
    Uri url = Uri.parse(
        'https://flutter-shopapp-4cd88-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken');
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
