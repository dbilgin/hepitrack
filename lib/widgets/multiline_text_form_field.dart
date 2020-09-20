import 'package:flutter/material.dart';

class MultilineTextFormField extends StatelessWidget {
  final TextEditingController textController;
  final Function onChanged;
  final String initialValue;
  MultilineTextFormField(
      {this.textController, this.onChanged, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(25.0),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 250,
        child: TextFormField(
          initialValue: initialValue,
          controller: textController,
          onChanged: (value) {
            if (onChanged != null) {
              onChanged(value);
            }
          },
          maxLength: 250,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: new InputDecoration(
            labelText: "Description",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
