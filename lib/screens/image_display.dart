import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:hepitrack/widgets/photo_view_swipe.dart';
import 'package:path/path.dart' as p;
import 'package:photo_view/photo_view.dart';

class ImageDisplay extends StatelessWidget {
  final String _uri;
  final String _heroString;
  ImageDisplay(this._uri, this._heroString);

  _shareImage(uri) async {
    var file = File(uri);
    await Share.file(
      p.basenameWithoutExtension(file.path),
      p.basename(file.path),
      file.readAsBytesSync(),
      'image/*',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PhotoViewSwipe(
        heroAttributes: PhotoViewHeroAttributes(tag: _heroString),
        imageProvider: FileImage(
          File(_uri),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _shareImage(_uri);
        },
        tooltip: 'Share',
        child: new Icon(Icons.share),
      ),
    );
  }
}
