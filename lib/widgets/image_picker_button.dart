import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hepitrack/utils/bottom_sheet_actions.dart';

class ImagePickerButton extends StatefulWidget {
  ImagePickerButton({
    Key key,
    @required this.defaultAssetPath,
    this.onChanged,
    @required this.heroTag,
    this.initialFile,
  }) : super(key: key);

  final String defaultAssetPath;
  final Function onChanged;
  final String heroTag;
  final File initialFile;

  @override
  _ImagePickerButtonState createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  File _imageFile;

  @override
  void initState() {
    _imageFile = widget.initialFile;
    super.initState();
  }

  void _setImage(File imageFile) async {
    if (_imageFile != null && await _imageFile.exists()) {
      _imageFile.delete();
    }

    setState(() {
      _imageFile = imageFile;
    });
    widget.onChanged(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(25.0),
      ),
      onPressed: () {
        BottomSheetActions.settingImageModalBottomSheet(
          context,
          _setImage,
          _imageFile?.path ?? null,
          widget.heroTag,
        );
      },
      child: _imageFile != null
          ? Hero(
              tag: widget.heroTag,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(25.0),
                  image: DecorationImage(
                    alignment: Alignment(0, 0),
                    image: new FileImage(_imageFile),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          : Container(
              height: 160,
              child: Image.asset(
                widget.defaultAssetPath,
                color: Theme.of(context).primaryColor,
                height: 128,
                width: 128,
              ),
            ),
    );
  }
}
