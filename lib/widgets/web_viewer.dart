import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hepitrack/widgets/error_display.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewer extends StatefulWidget {
  WebViewer(this.url);
  final dynamic url;

  @override
  _WebViewerState createState() => _WebViewerState();
}

class _WebViewerState extends State<WebViewer> {
  Widget mainChild;

  @override
  void initState() {
    mainChild = WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      gestureNavigationEnabled: true,
      onWebResourceError: (error) {
        setState(() {
          mainChild = Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ErrorDisplay(
                  text: 'An error has occurred, please check you connection.',
                ),
              ],
            ),
          );
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return mainChild;
  }
}
