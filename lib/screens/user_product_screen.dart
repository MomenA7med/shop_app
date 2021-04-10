import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:flutter_complete_guide/screens/edit_product_screen.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import 'package:flutter_complete_guide/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

class UserProductScreen extends StatelessWidget{
  static const routeName = '/user-product';

  Future<void> refresh(BuildContext context) async{
    await Provider.of<Products>(context,listen: false).fetchAndSetProducts(true);
  }
  @override
  Widget build(BuildContext context) {
    //final products = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton( icon: Icon(Icons.add),onPressed: (){
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          },),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: refresh(context),
        builder: (ctx,snapshot) =>
        snapshot.connectionState == ConnectionState.waiting ?
        Center(child: CircularProgressIndicator(),) :
         RefreshIndicator(
          onRefresh: () => refresh(context),
          child: Consumer<Products>(
            builder: (ctx,products,_) => Padding(
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (ctx,i) => Column(
                  children: [
                    UserProductItem(
                          id: products.items[i].id,
                          title: products.items[i].title,
                          imageUrl: products.items[i].imageUrl
                      ),
                    Divider(color: Colors.black,),
                  ],
                ),
                itemCount: products.items.length,
              ),
            ),
          ),
        ),
      ),
    );
  }

}