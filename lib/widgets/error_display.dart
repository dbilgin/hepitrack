import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  ErrorDisplay({Key key, this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/error.png'),
        Text(text ?? 'An error has occurred.',
            style: Theme.of(context).textTheme.bodyText1),
      ],
    );
  }
}
