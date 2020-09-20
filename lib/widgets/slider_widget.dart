import 'package:flutter/material.dart';

import 'custom_slider_thumb_circle.dart';

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  final double min;
  final double max;
  final fullWidth;
  final Function onChanged;
  final double value;

  SliderWidget({
    this.sliderHeight = 48,
    this.max = 10,
    this.min = 0,
    this.fullWidth = false,
    this.onChanged,
    this.value,
  });

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.widget.fullWidth
          ? double.infinity
          : (this.widget.sliderHeight) * 5.5,
      height: (this.widget.sliderHeight),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: Theme.of(context).primaryColor,
          trackHeight: 4.0,
          thumbShape: CustomSliderThumbCircle(
            thumbRadius: this.widget.sliderHeight * .4,
            thumbBackground: Theme.of(context).primaryColor,
          ),
          overlayColor: Colors.white.withOpacity(.4),
          //valueIndicatorColor: Colors.white,
          activeTickMarkColor: Colors.white,
          inactiveTickMarkColor: Colors.red.withOpacity(.7),
        ),
        child: Slider(
          value: widget.value,
          min: widget.min,
          max: widget.max,
          onChanged: (value) {
            widget.onChanged(value);
          },
        ),
      ),
    );
  }
}
