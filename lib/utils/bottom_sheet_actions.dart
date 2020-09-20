import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hepitrack/screens/image_display.dart';
import 'package:hepitrack/utils/dialogs.dart';
import 'package:image_picker/image_picker.dart';

class BottomSheetActions {
  static void settingImageModalBottomSheet(
    context,
    _setImage(File newFile),
    String existingFilePath,
    String heroString,
  ) {
    void _getImage(ImageSource source) async {
      try {
        final image = await ImagePicker.pickImage(source: source);
        if (image != null && await image.exists()) {
          _setImage(image);
        }
      } catch (e) {
        if (e?.code == 'photo_access_denied') {
          Dialogs.showPermission(context);
        } else {
          Dialogs.showCustomDialog(context: context);
        }
      }
      Navigator.pop(context);
    }

    List<Widget> _sheetChildren = [
      new ListTile(
        leading: new Icon(Icons.camera_alt),
        title: new Text('Camera'),
        onTap: () async {
          _getImage(ImageSource.camera);
        },
      ),
      new ListTile(
        leading: new Icon(Icons.photo_album),
        title: new Text('Gallery'),
        onTap: () async {
          _getImage(ImageSource.gallery);
        },
      ),
    ];

    if (existingFilePath != null) {
      _sheetChildren.add(
        new ListTile(
          leading: new Icon(Icons.fullscreen),
          title: new Text('View'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) =>
                    ImageDisplay(existingFilePath, heroString),
              ),
            );
          },
        ),
      );
      _sheetChildren.add(
        new ListTile(
          leading: new Icon(Icons.delete),
          title: new Text('Delete'),
          onTap: () {
            _setImage(null);
            Navigator.pop(context);
          },
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: SafeArea(
            child: new Wrap(
              children: _sheetChildren,
            ),
          ),
        );
      },
    );
  }
}
