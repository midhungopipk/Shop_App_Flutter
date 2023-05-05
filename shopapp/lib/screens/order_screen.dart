import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/orders.dart';
import 'package:shopapp/widgets/app_drawer.dart';
import 'package:shopapp/widgets/order_items.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  static const routeName = '/orders';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // var _isLoading = false;
  // @override
  // void initState() {
  //   Future.delayed(Duration.zero).then((_) async {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });

  //   super.initState();
  // }

  // thwo ways we can do the calling of fetchAndSetOrders()
  // 1. using FutureBuilder
  // 2. Calling the fetchAndSet() in the initState method after converting to stateFullWidget

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Orders"),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
            future: orderData.fetchAndSetOrders(),
            builder: (ctx, dataSnapShot) {
              if (dataSnapShot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (dataSnapShot.error != null) {
                  return const Center(
                    child: Text('An error occured'),
                  );
                } else {
                  return Consumer<Orders>(
                    builder: (ctx, orderData, child) => ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (ctx, index) =>
                          OrderItems(orderData.orders[index]),
                    ),
                  );
                }
              }
            })

        //  _isLoading
        //     ? const Center(child: CircularProgressIndicator())
        //     : ListView.builder(
        //         itemCount: orderData.orders.length,
        //         itemBuilder: (ctx, index) => OrderItems(orderData.orders[index]),
        //       ),
        );
  }
}
