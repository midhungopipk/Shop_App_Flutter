import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/product_grid.dart';
import '../providers/products.dart';

enum FilterOptions { Favourites, All }

class ProductsOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              if (selectedValue == FilterOptions.Favourites) {
                productData.showFavouritesOnly();
              } else {
                productData.showAll();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.Favourites,
                child: Text('Only Favourites.'),
              ),
              const PopupMenuItem(
                value: FilterOptions.All,
                child: Text('Show All.'),
              )
            ],
            icon: const Icon(Icons.more_vert),
          )
        ],
      ),
      body: ProductGrid(),
    );
  }
}
