import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/orders.dart' as ords;
import 'package:intl/intl.dart';

import 'cart_item.dart';

class OrderItem extends StatefulWidget{
  final ords.OrderItem order;
  OrderItem({@required this.order});

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> with SingleTickerProviderStateMixin{
  bool _expande = false;
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,duration: Duration(milliseconds: 700));
    _offsetAnimation = Tween<Offset>(begin: Offset(0.0,1.5),end: Offset(0.0,0.0))
        .animate(CurvedAnimation(parent: _controller,curve: Curves.elasticIn));
    _controller.forward();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime).toString()),
            trailing: IconButton(
              icon: Icon(_expande ? Icons.expand_less : Icons.expand_more),
              onPressed: (){
                setState(() {
                  _expande = !_expande;
                });
              },
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.decelerate,
            height: _expande ? min(widget.order.Products.length * 40.0 + 100 , 180) : 0,
            constraints: BoxConstraints(
              minHeight: _expande ? min(widget.order.Products.length * 40.0 + 100 , 180) : 0,
            ),
            child: ListView.builder(itemBuilder: (ctx,i) => CartItem(
              title: widget.order.Products[i].title,
              quantity: widget.order.Products[i].quantity,
              id: widget.order.Products[i].id,
              price: widget.order.Products[i].price,
            ),
              itemCount: widget.order.Products.length,
            ),
          ),
        ],),
      ),
    );
  }
}