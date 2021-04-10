import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/helpers/custom_route.dart';
import 'package:flutter_complete_guide/providers/auth.dart';
import 'package:flutter_complete_guide/screens/orders_screen.dart';
import 'package:flutter_complete_guide/screens/user_product_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
      children: [
        AppBar(title: Text('SHOP APP'),
        automaticallyImplyLeading: false,),
        Divider(),
        ListTile(
          leading: Icon(Icons.shop),
          title: Text('shop'),
          onTap: (){
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.payment),
          title: Text('Orders'),
          onTap: (){
            Navigator.of(context).pushReplacementNamed(OrderScreen.reouteName);
            // Navigator.of(context).pushReplacement(
            //   CustomRoute(
            //     builder: (ctx) => OrderScreen(),
            //   ),
            // );
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Manage products'),
          onTap: (){
            Navigator.of(context).pushReplacementNamed(UserProductScreen.routeName);
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('logout'),
          onTap: (){
            Navigator.of(context).pop();
            Provider.of<Auth>(context,listen: false).logout();
          },
        ),
      ],
      ),
    );
  }

}