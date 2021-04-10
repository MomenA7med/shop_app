import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_complete_guide/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> Products;
  final DateTime dateTime;

  OrderItem({
   @required this.dateTime,
   @required this.id,
   @required this.Products,
   @required this.amount,
  });

}

class Orders with ChangeNotifier{
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken,this.userId,this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders () async {
    var query = {
      'auth' : authToken,
    };
    final url = Uri.https(
        'shop-app-2e5b5-default-rtdb.firebaseio.com', '/orders/$userId.json',query);
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String,dynamic>;
    if(extractedData == null) {
      print('null');
      return;
    }
    extractedData.forEach((orderid, orderData) {
      loadedOrders.add(
          OrderItem(
          dateTime: DateTime.parse(orderData['dateTime']),
          id: orderid,
          amount: orderData['amount'],
          Products: (orderData['products'] as List<dynamic>).map(
                  (item) =>
            CartItem(
              id: item['id'],
              title: item['title'],
              quantity: item['quantity'],
              price: item['price'],
            ),
          ).toList(),
      )
      );
    });
    print('done with count : ${loadedOrders.length}');
    _orders = loadedOrders;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts,double total) async {
    final timestamp = DateTime.now();
    var query = {
      'auth' : authToken,
    };
    final url = Uri.https(
        'shop-app-2e5b5-default-rtdb.firebaseio.com', '/orders/$userId.json',query);
    final response = await http.post(
      url,
      body: json.encode({
      'amount' : total,
      'dateTime' : timestamp.toIso8601String(),
      'products' : cartProducts.map((cp) => {
        'id' : cp.id,
        'title' : cp.title,
        'quantity' : cp.quantity,
        'price' : cp.price,
      }).toList(),
    }),);
    _orders.insert(0, OrderItem(
        dateTime: timestamp,
        id: json.decode(response.body)['name'],
        Products: cartProducts,
        amount: total,
    )
    );
    notifyListeners();
  }

}