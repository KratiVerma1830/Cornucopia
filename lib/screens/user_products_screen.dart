import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../widgets/user_product_item.dart';
import '../widgets/main_drawer.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user-products";

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Product"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
            )
          ],
        ),
        drawer: MainDrawer(),
        body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () {
                    return _refreshProducts(context);
                  },
                  child: Consumer<Products>(builder: (context, productData, _) {
                    final products = productData.items;
                    return Padding(
                      padding: EdgeInsets.all(8),
                      child: ListView.builder(
                        itemBuilder: (_, i) {
                          return Column(
                            children: <Widget>[
                              UserProductItem(
                                products[i].title,
                                products[i].imageUrl,
                                products[i].id,
                              ),
                              Divider()
                            ],
                          );
                        },
                        itemCount: products.length,
                      ),
                    );
                  }),
                ),
        ));
  }
}
