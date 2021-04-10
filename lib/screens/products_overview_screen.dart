import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/cart.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import 'package:flutter_complete_guide/widgets/badge.dart';
import 'package:provider/provider.dart';
import '../widgets/products_grid.dart';
import 'CartScreen.dart';

enum FilterOption {
  Favorite,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorite = false;
  var _isInit = true;
  var _isLoading = false;
  var _isError = false;

  @override
  void didChangeDependencies() {
    if (_isInit){
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts(false).catchError((onError){
        print('error : $onError');
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }).then((value) {
        setState(() {
          _isLoading = false;
        });
      }
      );
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //final productsContainer = Provider.of<Products>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(child: Text('Only favorites'),value: FilterOption.Favorite,),
              PopupMenuItem(child: Text('Show all'),value: FilterOption.All,),
            ],
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOption selectedItem) {
            print(selectedItem);
            setState(() {
              if (selectedItem == FilterOption.Favorite){
                //productsContainer.showFavoritesOnly();
                _showOnlyFavorite = true;
              } else {
                //productsContainer.showAll();
                _showOnlyFavorite = false;
              }
            });
          },
          ),
          Consumer<Cart>(
              builder: (_,cart,ch) => Badge(
                child: ch,
                value: cart.itemCount.toString(),
              ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading ? Center(child: CircularProgressIndicator()): ProductsGrid(_showOnlyFavorite,_isError),
    );
  }
}
