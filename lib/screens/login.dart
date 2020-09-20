import 'package:flutter/material.dart';
import 'package:hepitrack/services/auth_service.dart';
import 'package:hepitrack/services/storage_service.dart';
import 'package:hepitrack/utils/common.dart';
import 'package:hepitrack/utils/dialogs.dart';

class LoginPage extends StatelessWidget {
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
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 50,
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
                    FlatButton(
                      onPressed: () {
                        Dialogs.forgotPasswordDialog(context);
                      },
                      child: Text('Forgot password?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: Text('Login'),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();

                  var loginResult = await AuthService(
                    context: context,
                    showLoader: true,
                  ).login(_email, _password);

                  if (loginResult.statusCode == 200) {
                    var token = loginResult.data['access_token'];
                    await StorageService().writeUserData(token, _email);
                    await StorageService().writeVerified(
                      loginResult.data['verified'].toString(),
                    );
                    Dialogs.showCustomDialog(
                      context: context,
                      title: 'Login Successful',
                      message:
                          'You are now logged in, your data will be backed up at all times.',
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                    );
                  } else if (loginResult.statusCode == 400) {
                    Dialogs.showCustomDialog(
                      context: context,
                      message: 'Please check your credentials and try again.',
                    );
                  } else if (loginResult.statusCode == 401) {
                    Dialogs.showCustomDialog(
                      context: context,
                      title: 'Wrong credentials',
                      message: 'Please check your credentials and try again.',
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
