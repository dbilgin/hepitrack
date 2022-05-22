import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:hepitrack/main.dart';
import 'package:hepitrack/models/body_part.dart';
import 'package:hepitrack/models/symptom.dart';
import 'package:hepitrack/models/symptom_track_item.dart';
import 'package:hepitrack/utils/db.dart';
import 'package:hepitrack/widgets/error_display.dart';
import 'package:hepitrack/widgets/loader_display.dart';
import 'package:hepitrack/widgets/slider_widget.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

class SymptomPage extends StatefulWidget {
  SymptomPage({this.symptomTrackItem});
  final SymptomTrackItem symptomTrackItem;

  @override
  _SymptomPageState createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage>
    with SingleTickerProviderStateMixin {
  String _appBarText = '';
  SymptomTrackItem _symptomTrackItem;
  Symptom _selectedSymptom;
  double _selectedIntensity;

  AnimationController _animationController;
  Animation<Color> _colorTween;

  final formKey = new GlobalKey<FormState>();

  Future<List<Symptom>> _symptoms;
  Future<List<BodyPart>> _bodyParts;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    new Future.delayed(Duration.zero, () {
      setState(() {
        _colorTween = ColorTween(
          begin: Theme.of(context).scaffoldBackgroundColor,
          end: Colors.red,
        ).animate(_animationController);
      });
    });

    if (widget.symptomTrackItem != null) {
      _symptomTrackItem = widget.symptomTrackItem;
      _appBarText = 'Edit Symptom';
      _setSymptom();
      _selectedIntensity = _symptomTrackItem.intensity.toDouble();
      _animationController.animateTo(_selectedIntensity / 10);
    } else {
      _symptomTrackItem = new SymptomTrackItem();
      _appBarText = 'Add Symptom';
      _selectedIntensity = 0;
    }

    _symptoms = DB.symptoms();
    _bodyParts = DB.bodyParts();
    super.initState();
  }

  _setSymptom() async {
    if (_symptomTrackItem.symptom != null) {
      Symptom existingSymptom = await DB.symptom(_symptomTrackItem.symptom);
      setState(() {
        _selectedSymptom = existingSymptom;
      });
    }
  }

  _saveForm() {
    var form = formKey.currentState;
    if (form.validate()) {
      Navigator.pop(
        context,
        _symptomTrackItem,
      );
    }
  }

  Widget symptomDropdown() {
    return FutureBuilder<List<Symptom>>(
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorDisplay();
        } else if (snapshot.hasData) {
          return DropdownButtonFormField(
            items: snapshot.data.map((Symptom symptom) {
              return new DropdownMenuItem(
                value: symptom.id,
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 12),
                      height: 32,
                      width: 32,
                      child: Image.asset(symptom.image),
                    ),
                    Text(symptom.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (int newValue) {
              Symptom selectedSymptom =
                  snapshot.data.firstWhere((symptom) => symptom.id == newValue);
              setState(() {
                _selectedSymptom = selectedSymptom;
                _symptomTrackItem.symptom = newValue;

                // Set the body parts
                if (selectedSymptom.defaultBodyPart != null) {
                  _symptomTrackItem.bodyParts = [
                    selectedSymptom.defaultBodyPart
                  ];
                } else {
                  _symptomTrackItem.bodyParts = [];
                }
              });
            },
            value: _symptomTrackItem.symptom,
            validator: (value) {
              if (value == null) {
                return 'A symptom needs to be selected';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: DynamicTheme.of(context).themeId == AppThemes.Light
                  ? Colors.grey[200]
                  : Theme.of(context).scaffoldBackgroundColor,
              hintText: 'Select a symptom',
            ),
          );
        } else {
          return LoaderDisplay();
        }
      },
      future: _symptoms,
    );
  }

  Widget bodyPartsDropdown() {
    return FutureBuilder<List<BodyPart>>(
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorDisplay();
        } else if (snapshot.hasData) {
          return MultiSelectFormField(
            dataSource: snapshot.data
                .map((bodyPart) =>
                    {'value': bodyPart.id, 'display': bodyPart.name})
                .toList(),
            onSaved: (values) {
              if (values == null) return;

              List<int> parts = [];
              values.forEach((value) {
                parts.add(value);
              });

              setState(() {
                _symptomTrackItem.bodyParts = parts;
              });
            },
            initialValue: _symptomTrackItem.bodyParts,
            textField: 'display',
            valueField: 'value',
            hintWidget: Text('Pick the affected body parts'),
            okButtonLabel: 'OK',
            cancelButtonLabel: 'CANCEL',
            title: Text('Body Part'),
          );
        } else {
          return LoaderDisplay();
        }
      },
      future: _bodyParts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Scaffold(
        backgroundColor: _colorTween.value,
        appBar: AppBar(
          title: Text(_appBarText),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  symptomDropdown(),
                  if (_symptomTrackItem.symptom != null &&
                      _selectedSymptom != null &&
                      _selectedSymptom.defaultBodyPart == null)
                    Container(
                      margin: EdgeInsets.only(top: 32),
                      child: bodyPartsDropdown(),
                    ),
                  if (_selectedSymptom != null)
                    Container(
                      margin: EdgeInsets.only(top: 32),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Symptom Intensity'),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 16),
                            child: SliderWidget(
                              value: _selectedIntensity,
                              onChanged: (double value) => setState(() {
                                _animationController.animateTo(value / 10);
                                _symptomTrackItem.intensity = value.round();
                                _selectedIntensity = value;
                              }),
                              fullWidth: true,
                              min: 0,
                              max: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Save',
          child: Icon(Icons.save),
          onPressed: () => _saveForm(),
        ),
      ),
    );
  }
}
