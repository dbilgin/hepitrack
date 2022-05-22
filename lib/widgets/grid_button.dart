import 'package:flutter/material.dart';

class GridButton extends StatelessWidget {
  GridButton({
    Key key,
    @required this.text,
    @required this.image,
    this.buttonCallback,
    this.isFilled = false,
  }) : super(key: key);

  final String text;
  final Image image;
  final VoidCallback buttonCallback;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: buttonCallback,
      color: isFilled
          ? Theme.of(context).focusColor
          : Theme.of(context).primaryColor,
      padding: EdgeInsets.zero,
      child: Stack(
        children: <Widget>[
          if (isFilled)
            Positioned(
              top: 5,
              right: 0,
              child: Icon(
                Icons.turned_in,
                color: Theme.of(context).focusColor,
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: image,
                  ),
                ),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
