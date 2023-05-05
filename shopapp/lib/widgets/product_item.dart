import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';

class Productitem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String description;
  // final double price;
  // final String imageUrl;
  // bool favourite;

  // Productitem(this.id, this.title, this.description, this.price, this.imageUrl,
  //     this.favourite);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
//if u use consumer and wrap it around the widget that only want an update that widget will only rebuild
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, _) {
              return IconButton(
                onPressed: () {
                  product.toggleFavourite();
                },
                icon: Icon(product.favourite
                    ? Icons.favorite
                    : Icons.favorite_outline_outlined),
                color: Theme.of(context).colorScheme.secondary,
              );
            },
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(
                product.id,
                product.title,
                product.price,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added item to the cart.'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                      label: "Undo",
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      }),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
