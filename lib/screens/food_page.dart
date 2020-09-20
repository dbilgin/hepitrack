import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hepitrack/models/food_track_item.dart';

import '../widgets/image_picker_button.dart';
import '../widgets/multiline_text_form_field.dart';

class FoodPage extends StatefulWidget {
  FoodPage({this.foodTrackItem});
  final FoodTrackItem foodTrackItem;

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  File _changedFile;
  FoodTrackItem _foodTrackItem;
  String _appBarText = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.foodTrackItem != null) {
      _foodTrackItem = widget.foodTrackItem;
      _appBarText = 'Edit Food';
    } else {
      _foodTrackItem = new FoodTrackItem();
      _appBarText = 'Add Food';
    }
    super.initState();
  }

  Future<bool> _onBackPressed() async {
    if (_changedFile != null && await _changedFile.exists()) {
      _changedFile.delete();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_appBarText),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: TextFormField(
                    initialValue: _foodTrackItem.name,
                    onChanged: (value) {
                      setState(() {
                        _foodTrackItem.name = value;
                      });
                    },
                    maxLength: 50,
                    decoration: InputDecoration(labelText: 'Food name*'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'The name field is required';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 16.0),
                  width: double.infinity,
                  child: ImagePickerButton(
                    initialFile: _foodTrackItem.image,
                    defaultAssetPath: 'assets/tracking/food.png',
                    onChanged: (File file) {
                      setState(() {
                        _changedFile = file;
                        _foodTrackItem.image = file;
                      });
                    },
                    heroTag: 'foodImageHero',
                  ),
                ),
                MultilineTextFormField(
                  initialValue: _foodTrackItem.description,
                  onChanged: (value) {
                    setState(() {
                      _foodTrackItem.description = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Save',
          child: Icon(Icons.save),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              Navigator.pop(
                context,
                _foodTrackItem,
              );
            }
          },
        ),
      ),
    );
  }
}
