import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget{
  static const routeName = '/route-edit';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  var _isInit = true;
  var _isLoading = false;
  var _isError = false;
  var _intValue = {
    'title' : '',
    'description' : '',
    'price' : '',
    'imageUrl' : '',
  };
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updatedImageUrl);
    super.initState();
  }


  @override
  void didChangeDependencies() {
    if (_isInit){
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null){
        _editedProduct = Provider.of<Products>(context,listen: false).findById(productId);
        _intValue = {
          'title' : _editedProduct.title,
          'description' : _editedProduct.description,
          'price' : _editedProduct.price.toString(),
          'imageUrl' : '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updatedImageUrl (){
    if(!_imageUrlFocusNode.hasFocus){
      setState(() {
      });
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updatedImageUrl);
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid){
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if(_editedProduct.id != null){
      print(_editedProduct.id);
      await Provider.of<Products>(context,listen: false).updateProduct(_editedProduct.id, _editedProduct);
    }
    else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        _isError = true;
            await showDialog<Null>(context: context, builder: (ctx) =>
            AlertDialog(
              content: Text('something went wronge !'),
              title: Text('an Error occurred '),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(),
                    child: Text('Ok'))
              ],
            ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    if (!_isError) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Product Added or Updated'),
      ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add or Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) :
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(children: [
            TextFormField(
              initialValue: _intValue['title'],
              decoration: InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_){
                FocusScope.of(context).requestFocus(_priceFocusNode);
              },
              validator: (value){
                if (value.isEmpty){
                  return 'Please provide a value';
                }
                return null;
              },
              onSaved: (value) {
                _editedProduct = Product(
                  isFavorite: _editedProduct.isFavorite,
                  id: _editedProduct.id,
                  imageUrl: _editedProduct.imageUrl,
                  title: value,
                  description: _editedProduct.description,
                  price: _editedProduct.price,
                );
              },
            ),
            TextFormField(
              initialValue: _intValue['price'],
              decoration: InputDecoration(labelText: 'Price'),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_){
                FocusScope.of(context).requestFocus(_descFocusNode);
              },
              focusNode: _priceFocusNode,
              validator: (value) {
                if (value.isEmpty){
                  return 'Please provide a value';
                }
                if (double.tryParse(value) == null){
                  return 'please inter valid number';
                }
                if (double.parse(value) <= 0){
                  return 'please inter number greater than zero';
                }
                return null;
              },
              onSaved: (value) {
                _editedProduct = Product(
                  isFavorite: _editedProduct.isFavorite,
                  id: _editedProduct.id,
                  imageUrl: _editedProduct.imageUrl,
                  title: _editedProduct.title,
                  description: _editedProduct.description,
                  price: double.parse(value),
                );
              },
            ),
            TextFormField(
              initialValue: _intValue['description'],
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              focusNode: _descFocusNode,
              validator: (value) {
                if (value.isEmpty){
                  return 'Please provide a value';
                }
                return null;
              },
              onSaved: (value) {
                _editedProduct = Product(
                  isFavorite: _editedProduct.isFavorite,
                  id: _editedProduct.id,
                  imageUrl: _editedProduct.imageUrl,
                  title: _editedProduct.title,
                  description: value,
                  price: _editedProduct.price,
                );
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  margin: EdgeInsets.only(
                    top: 8,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.grey,
                    ),
                  ),
                  child:
                  _imageUrlController.text.isEmpty ?
                  Text('Enter URL') :
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FittedBox(
                      child: Image.network(_imageUrlController.text),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Image URL'),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    controller: _imageUrlController,
                    onEditingComplete: (){
                      setState(() {
                        _saveForm();
                      });
                    },
                    focusNode: _imageUrlFocusNode,
                    validator: (value) {
                      if (value.isEmpty){
                        return 'Please provide a value';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                        isFavorite: _editedProduct.isFavorite,
                        id: _editedProduct.id,
                        imageUrl: value,
                        title: _editedProduct.title,
                        description: _editedProduct.description,
                        price: _editedProduct.price,
                      );
                    },
                  ),
                )
              ],
            ),
          ],),
        ),
      ),
    );
  }
}