import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/cart.dart';

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
  final token;
  final uid;
  List<OrderItem> _orders = [];

  Orders(this.token, this._orders, this.uid);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        "https://cornucopia-17f73.firebaseio.com/Orders/$uid.json?auth=$token";
    final response = await http.get(Uri.parse(url));
    final List<OrderItem> orders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    extractedData.forEach((id, order) {
      orders.add(OrderItem(
        id: id,
        amount: order["Amount"],
        products: (order["Products"] as List<dynamic>)
            .map(
              (map) => CartItem(
                id: map["id"],
                quantity: map["quantity"],
                price: map["price"],
                title: map["title"],
              ),
            )
            .toList(),
        dateTime: DateTime.parse(order["Date"]),
      ));
    });
    _orders = orders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartItems, double total) async {
    final url =
        "https://cornucopia-17f73.firebaseio.com/Orders/$uid.json?auth=$token";
    final timeStamp = DateTime.now();
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          "Amount": total,
          "Date": timeStamp.toIso8601String(),
          "Products": cartItems.map((item) {
            return {
              "id": item.id,
              "title": item.title,
              "price": item.price,
              "quantity": item.quantity,
            };
          }).toList()
        }));
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)["name"],
            amount: total,
            dateTime: timeStamp,
            products: cartItems));
    notifyListeners();
  }
}
