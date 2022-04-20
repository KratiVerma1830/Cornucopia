import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../widgets/product_item.dart';
import '../providers/products_provider.dart';

class ProductsGrid extends StatelessWidget {
 final bool showFav;
 ProductsGrid(this.showFav);
  @override
  Widget build(BuildContext context) {
    final productData  = Provider.of<Products>(context);
    final products = showFav?productData.favouriteItems:productData.items;
    return GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemBuilder: (context, i) => ChangeNotifierProvider.value(
                  value:products[i],
                  child: ProductItem(),
        ));
  }
}