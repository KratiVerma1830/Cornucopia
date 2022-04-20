import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  final String authToken;
  final String uid;
  Products(this.authToken, this._items, this.uid);

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get favouriteItems {
    return _items.where((element) => element.isFavourite == true).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere(
      (product) => product.id == id,
    );
  }

  Future<void> fetchAndSetProducts([bool filter = false]) async {
    final filterString = filter ? '&orderBy="UID"&equalTo="$uid"' : '';
    var url =
        'https://cornucopia-17f73.firebaseio.com/Products.json?auth=$authToken$filterString';
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    final List<Product> products = [];
    if (extractedData == null) {
      return;
    }
    url =
        "https://cornucopia-17f73.firebaseio.com/UserFavourites/$uid.json?auth=$authToken";
    final favouriteResponse = await http.get(Uri.parse(url));
    final favouriteData = json.decode(favouriteResponse.body);
    extractedData.forEach((id, product) {
      products.add(Product(
        id: id,
        title: product["Title"],
        description: product["Description"],
        price: product["Price"],
        imageUrl: product["ImgUrl"],
        isFavourite: favouriteData == null ? false : favouriteData[id] ?? false,
      ));
    });
    _items = products;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final url =
        "https://cornucopia-17f73.firebaseio.com/Products.json?auth=$authToken";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          "Title": product.title,
          "Description": product.description,
          "ImgUrl": product.imageUrl,
          "Price": product.price,
          "UID": uid
        }),
      );
      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)["name"]);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final url =
          "https://cornucopia-17f73.firebaseio.com/Products/$id.json?auth=$authToken";
      await http.patch(Uri.parse(url),
          body: json.encode({
            "Title": newProduct.title,
            "Description": newProduct.description,
            "ImgUrl": newProduct.imageUrl,
            "Price": newProduct.price,
          }));
      _items[index] = newProduct;
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://cornucopia-17f73.firebaseio.com/Products/$id.json?auth=$authToken";
    final existingIndex = _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingIndex];
    _items.removeAt(existingIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode >= 400) {
      _items.insert(existingIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product");
    }
    existingProduct = null;
  }
}
