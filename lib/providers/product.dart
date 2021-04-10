import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
}

  Future<void> toggleFavoriteStatus(String authToken,String userId) async {
    var query = {
      'auth' : authToken,
    };
    final oldFavorite = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.https(
        'shop-app-2e5b5-default-rtdb.firebaseio.com', '/userFavorite/$userId/$id.json',query);
    try{
      final response = await http.put(url,body: json.encode(
      isFavorite,
      ));
      if (response.statusCode >= 400) {
        _setFavValue(oldFavorite);
      }
    }catch(error){
      _setFavValue(oldFavorite);
    }
  }
}
