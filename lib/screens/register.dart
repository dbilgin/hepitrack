import 'package:flutter/material.dart';
import 'package:hepitrack/services/auth_service.dart';
import 'package:hepitrack/services/storage_service.dart';
import 'package:hepitrack/utils/common.dart';
import 'package:hepitrack/utils/dialogs.dart';

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  var _email;
  var _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      onSaved: (newValue) => _email = newValue,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 50,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'The email field is required';
                        } else if (!Common.isValidEmail(value)) {
                          return 'Enter valid email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      onSaved: (newValue) => _password = newValue,
                      obscureText: true,
                      maxLength: 50,
                      decoration: InputDecoration(labelText: 'Password'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'The password field is required';
                        } else if (value.length < 6) {
                          return 'The password field must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: Text('Register'),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();

                  var registerResult = await AuthService(
                    context: context,
                    showLoader: true,
                  ).register(_email, _password);

                  if (registerResult.statusCode == 200) {
                    var token = registerResult.data['access_token'];
                    await StorageService().writeUserData(token, _email);
                    Dialogs.showCustomDialog(
                      context: context,
                      title: 'Email Verification',
                      message: 'Account created! Please verify your email.',
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                    );
                  } else if (registerResult.statusCode == 400 ||
                      registerResult.statusCode == 409) {
                    Dialogs.showCustomDialog(
                      context: context,
                      message: 'Please check your information and try again.',
                    );
                  } else {
                    Dialogs.showCustomDialog(context: context);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
