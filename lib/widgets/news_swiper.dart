import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:hepitrack/utils/dialogs.dart';

class NewsSwiper extends StatefulWidget {
  NewsSwiper(this.jsonBody);
  final dynamic jsonBody;

  @override
  _NewsSwiperState createState() => _NewsSwiperState();
}

class _NewsSwiperState extends State<NewsSwiper> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Text('Health News'),
          Expanded(
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => Dialogs.showWebView(
                      context, widget.jsonBody[index]['url']),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        child: Image.asset(
                          'assets/news.png',
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        child: Text(
                          widget.jsonBody[index]['title'],
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(top: 8),
                          child: Text(
                            widget.jsonBody[index]['source'],
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: widget.jsonBody.length,
              viewportFraction: 0.8,
              scale: 0.9,
              autoplay: true,
              autoplayDelay: 20000,
            ),
          ),
        ],
      ),
    );
  }
}
