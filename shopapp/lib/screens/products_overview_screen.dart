import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/cart.dart';
import 'package:shopapp/screens/cart_screen.dart';
import 'package:shopapp/widgets/app_drawer.dart';

import '../widgets/product_grid.dart';
import '../providers/products.dart';

enum FilterOptions { Favourites, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavourites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts();  WON't work we cont get context here
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(
        () {
          _isLoading = true;
        },
      );
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }

    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Shop',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favourites) {
                  _showOnlyFavourites = true;
                } else {
                  _showOnlyFavourites = false;
                }
              });
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
          ),
          Consumer<Cart>(
            builder: (ctx, cartData, ch) {
              return Badge(
                  label: Text(cartData.cartItems.toString()), child: ch);
            },
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
          //providing iconButton as child prevent rebuilt
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(_showOnlyFavourites),
    );
  }
}
