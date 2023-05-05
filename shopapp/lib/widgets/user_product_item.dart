import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/products.dart';
import 'package:shopapp/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(EditProductScreen.routeName, arguments: id);
                },
                icon: const Icon(Icons.edit),
                color: Theme.of(context).colorScheme.primary),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text(
                      "Are you sure?",
                      style: TextStyle(color: Colors.black),
                    ),
                    content: const Text('Do you want to remove this product?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text("No"),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            Navigator.of(ctx).pop(true);
                            await Provider.of<Products>(context, listen: false)
                                .deleteProduct(id);
                          } catch (e) {
                            scaffold.showSnackBar(const SnackBar(
                                content: Text('Deletion failed!!')));
                          }
                        },
                        child: const Text("Yes"),
                      )
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete),
              color: Theme.of(context).colorScheme.error,
            )
          ],
        ),
      ),
    );
  }
}
