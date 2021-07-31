import 'package:flutter/material.dart';
import 'package:real_shop/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/products.dart';
import 'package:real_shop/widgets/user_product_item.dart';
import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user_products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.routeName),
            icon: Icon(Icons.add),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, AsyncSnapshot snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    child: Consumer<Products>(
                      builder: (ctx, productData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                            itemCount: productData.items.length,
                            itemBuilder: (_, int index) => Column(
                                  children: [
                                    UserProductItem(
                                        productData.items[index].id,
                                        productData.items[index].title,
                                        productData.items[index].imageUrl),
                                    Divider(),
                                  ],
                                )),
                      ),
                    ),
                    onRefresh: () => _refreshProducts(context)),
      ),
    );
  }
}
