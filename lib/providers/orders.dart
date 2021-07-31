import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:real_shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> orders = [];
  String authTok;
  String userId;

  getData(String authToken, String uId, List<OrderItem> products) {
    authToken = authTok;
    userId = uId;
    orders = products;
    notifyListeners();
  }

  List<OrderItem> get items {
    return [...orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://shop-93fa3-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authTok';

    try {
      final res = await http.get(url);

      //------ data here is stored as map and doesnt extracted yet.
      final extractedData = json.decode(res.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      // ------- extract data form var extractedData

      final List<OrderItem> loadedOrders = [];

      // -------------------- key --- value
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map((item) => CartItem(
                      id: item['id'],
                      price: item['price'],
                      quantity: item['quantity'],
                      title: item['title'],
                    ))
                .toList(),
          ),
        );
      });
      orders = loadedOrders.reversed.toList();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final url =
        'https://shop-93fa3-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authTok';
    try {
      final timeStamp = DateTime.now();
      final res = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProduct
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
          }));
      orders.insert(
          0,
          OrderItem(
            id: json.decode(res.body)['name'],
            amount: total,
            dateTime: timeStamp,
            products: cartProduct,
          ));
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
