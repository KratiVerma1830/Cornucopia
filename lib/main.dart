import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import './screens/edit_product_screen.dart';
import './screens/user_products_screen.dart';
import './screens/product_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products_provider.dart';
import './providers/cart.dart';
import './providers/auth.dart';
import './screens/cart_screen.dart';
import 'providers/order.dart';
import './screens/order_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          return Auth();
        }),
        ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products("", [], ""),
            update: (context, auth, previousProducts) {
              return Products(
                  auth.token as String,
                  previousProducts == null ? [] : previousProducts.items,
                  auth.uid as String);
            }),
        ChangeNotifierProvider(create: (context) {
          return Cart();
        }),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) {
            return Orders("", [], "");
          },
          update: (context, auth, previousOrders) {
            return Orders(auth.token,
                previousOrders == null ? [] : previousOrders.orders, auth.uid);
          },
        )
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Cornucopia",
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: "Lato"),
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SplashScreen();
                      }
                      return AuthScreen();
                    },
                  ),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          );
        },
      ),
    );
  }
}
