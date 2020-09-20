import 'package:flutter/material.dart';
import 'package:hepitrack/providers/track_view_provider.dart';
import 'package:provider/provider.dart';

class TrackHandle extends StatefulWidget {
  TrackHandle({Key key, this.dragUpdate, this.dragEnd}) : super(key: key);
  final Function dragUpdate;
  final Function dragEnd;

  @override
  _TrackHandleState createState() => _TrackHandleState();
}

class _TrackHandleState extends State<TrackHandle> {
  bool _showLine = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) => setState(() {
        FocusScope.of(context).unfocus();
        _showLine = true;
      }),
      onVerticalDragUpdate: (details) => widget.dragUpdate(
          MediaQuery.of(context).size.height -
              details.globalPosition.dy -
              Provider.of<TrackViewProvider>(context, listen: false)
                  .saveButtonHeight -
              20),
      onVerticalDragEnd: (details) {
        setState(() {
          _showLine = false;
        });
        widget.dragEnd();
      },
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _showLine ? 1.0 : 0.0,
              child: Container(
                color: Theme.of(context).primaryColor,
                height: 1,
                width: double.infinity,
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.drag_handle,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
