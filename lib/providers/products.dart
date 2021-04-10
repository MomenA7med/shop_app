import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this.authToken,this.userId,this._items);

  //var _showFavoriteOnly = false;

  List<Product> get items {
    // if (_showFavoriteOnly) {
    //   return _items.where((productItem) => productItem.isFavorite == true).toList();
    //   }
    // else {
      return [..._items];
    // }
  }

  List<Product> get itemsFavorite {
    return _items.where((productItem) => productItem.isFavorite == true).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product item) async {
    var query = {
      'auth' : authToken,
    };
    try {
      final url = Uri.https(
          'shop-app-2e5b5-default-rtdb.firebaseio.com', '/products.json',query);
    final response = await http.post(url, body: json.encode({
      'title': item.title,
      'description': item.description,
      'price': item.price,
      'imageUrl': item.imageUrl,
      'creatorId': userId,
    }),);
    final newProduct = Product(
      id: json.decode(response.body)['name'],
      title: item.title,
      description: item.description,
      price: item.price,
      imageUrl: item.imageUrl,
    );
    _items.insert(0, newProduct);
    notifyListeners();
  }catch (error){
      print(error.toString());
      throw(error);
    }
  }

  Future<void> fetchAndSetProducts ([bool filterByUser = true]) async {
    var queryFilter = {
      'auth' : authToken,
      'orderBy' : '"creatorId"',
      'equalTo' : '"$userId"',
    };
    var query = {
      'auth' : authToken,
    };
    try {
      var url = Uri.https(
          'shop-app-2e5b5-default-rtdb.firebaseio.com', '/products.json',filterByUser ? queryFilter : query);
      print(url.toString());
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String , dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.https(
          'shop-app-2e5b5-default-rtdb.firebaseio.com', '/userFavorite/$userId.json',query);
      //final url = Uri.parse('shop-app-2e5b5-default-rtdb.firebaseio.com/products.json?auth=$authToken');
      final responseFavorite = await http.get(url);
      final favoriteData = json.decode(responseFavorite.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      if (_items == null){
        print('items is null');
      }
      notifyListeners();
    }catch (error) {
      throw (error);
    }
  }



  Future<void> updateProduct (String id,Product newProduct)async{
    var query = {
      'auth' : authToken,
    };
    final index = _items.indexWhere((element) => element.id == id);
    if(index >= 0){
      final url = Uri.https(
          'shop-app-2e5b5-default-rtdb.firebaseio.com', '/products.json',query);
      await http.patch(url,body: json.encode({
        'title' : newProduct.title,
        'description' : newProduct.description,
        'price' : newProduct.price,
        'imageUrl' : newProduct.imageUrl,
      }));
      _items[index] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct (String id) async{
    var query = {
      'auth' : authToken,
    };
    final url = Uri.https(
        'shop-app-2e5b5-default-rtdb.firebaseio.com', '/products.json',query);
    final existingProductIndex = _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException('could not delete Product');
      }
      existingProduct = null;
  }
}
