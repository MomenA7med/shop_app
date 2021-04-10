import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/orders.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import 'package:flutter_complete_guide/widgets/order_item.dart' as orditm;
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget{
  static const reouteName = '/orders';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future _orderFutures;
  Future _obtainOrders (){
    return Provider.of<Orders>(context,listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _orderFutures = _obtainOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(future: _orderFutures, builder: (ctx,dataSnapShot) {
        if (dataSnapShot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
          } else {
          if (dataSnapShot.connectionState == ConnectionState.done) {
            return Consumer<Orders>(
              builder: (ctx, orders, child) {
                return ListView.builder(
                  itemBuilder: (ctx, index) =>
                      orditm.OrderItem(order: orders.orders[index]),
                  itemCount: orders.orders.length,
                );
              },
            );
         } else {
           return Center(child: Text('An error occurred .'),);
        }
        }
        },),
    );
  }
}