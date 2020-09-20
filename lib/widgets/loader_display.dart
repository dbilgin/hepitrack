import 'package:flutter/material.dart';

class LoaderDisplay extends StatelessWidget {
  LoaderDisplay({Key key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: CircularProgressIndicator(),
        width: 30,
        height: 30,
      ),
    );
  }
}
