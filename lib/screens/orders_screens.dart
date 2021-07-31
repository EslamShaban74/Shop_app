import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/widgets/app_drawer.dart';
import 'package:real_shop/widgets/order_item.dart';
import 'package:real_shop/providers/orders.dart' show Orders;

class OrderScreen extends StatelessWidget {
  static const routeName = '/order';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Order')),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return Consumer<Orders>(
              builder: (ctx, orderData, child) => ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (BuildContext context, int index) => OrderItem(
                  orderData.orders[index],
                ),
              ),
            );
          }),
    );
  }
}
