import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/auth.dart';
import 'package:shopapp/providers/cart.dart';
import 'package:shopapp/providers/orders.dart';
import 'package:shopapp/providers/product.dart';
import 'package:shopapp/screens/auth_screen.dart';
import 'package:shopapp/screens/cart_screen.dart';
import 'package:shopapp/screens/edit_product_screen.dart';
import 'package:shopapp/screens/order_screen.dart';
import 'package:shopapp/screens/spash_screen.dart';
import 'package:shopapp/screens/user_products_screen.dart';
import './providers/products.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (ctx) => Products('', '', []),
            update: (ctx, auth, prevProducts) => Products(
              auth.token.toString(),
              auth.userId.toString(),
              prevProducts == null ? [] : prevProducts.items,
            ),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          // ChangeNotifierProvider(
          //   create: (ctx) => Orders(),
          // ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders('', '', []),
            update: (ctx, auth, previous) => Orders(
                auth.token.toString(),
                auth.userId.toString(),
                previous == null ? [] : previous.orders),
          )
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Shop App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.cyan,
              ).copyWith(
                secondary: Colors.deepOrange,
              ),
              fontFamily: 'Lato',
              textTheme: const TextTheme(
                titleLarge: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            // home: ProductsOverviewScreen(),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapShot) {
                      print(authResultSnapShot);
                      print("${auth.isAuth} is authenticated");
                      if (authResultSnapShot.connectionState ==
                          ConnectionState.waiting) {
                        return SplashScreen();
                      } else {
                        return AuthScreen();
                      }
                    }
                    // print(authResultSnapShot);
                    //     authResultSnapShot.connectionState ==
                    //             ConnectionState.waiting
                    //         ? SplashScreen()
                    //         : AuthScreen(),
                    ),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrderScreen.routeName: (ctx) => OrderScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen()
            },
          ),
        ));
  }
}
