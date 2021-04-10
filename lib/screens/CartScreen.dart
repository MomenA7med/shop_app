import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/cart.dart';
import 'package:flutter_complete_guide/providers/orders.dart';
import 'package:flutter_complete_guide/widgets/cart_item.dart' as ci;
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget{
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('your cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Row(children: [
                Text('total ',style: TextStyle(fontSize: 20),),
                SizedBox(width: 10,),
                Chip(
                    label: Text('\$${cart.totalAmount}',style: TextStyle(
                      color: Theme.of(context).primaryTextTheme.headline6.color,
                    ),),
                    backgroundColor: Theme.of(context).primaryColor,
                ),
                Spacer(),
                OrderButton(cart: cart),
              ],),
            ),
          ),
          ListView.builder(
            scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (ctx,index) => ci.CartItem(
                  title: cart.items.values.toList()[index].title,
                  productId: cart.items.keys.toList()[index],
                  id: cart.items.values.toList()[index].id,
                  quantity: cart.items.values.toList()[index].quantity,
                  price: cart.items.values.toList()[index].price
              ),
            itemCount: cart.items.length,
          ),
        ],
      ),
    );
  }

}

class OrderButton extends StatefulWidget{
  final Cart cart;
  const OrderButton({
    Key key,
    @required this.cart
}) : super (key: key);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)? null :() async {
        setState(() {
          _isLoading = true;
        });
        await Provider.of<Orders>(context,listen: false).addOrder(
            widget.cart.items.values.toList(),
            widget.cart.totalAmount);
        setState(() {
          _isLoading = false;
        });
        widget.cart.clear();
      },
    );
  }
}
