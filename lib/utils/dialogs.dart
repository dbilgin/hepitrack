import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hepitrack/services/auth_service.dart';
import 'package:hepitrack/services/storage_service.dart';
import 'package:hepitrack/widgets/web_viewer.dart';

import 'common.dart';

class Dialogs {
  static showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: [new CircularProgressIndicator()],
            ),
          ),
          onWillPop: () async {
            return false;
          },
        );
      },
    );
  }

  static showWebView(BuildContext context, String url) {
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return SafeArea(
          child: Container(
            margin: EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                color: Colors.white,
                child: WebViewer(url),
              ),
            ),
          ),
        );
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 150),
    );
  }

  static showPermission(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permissions"),
          content: Text(
              "You need to give necessary permissions to use this feature."),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static showCustomDialog({
    @required BuildContext context,
    String title = 'Error',
    String message = 'An error has occurred, please try again later.',
    Function onPressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
                if (onPressed != null) onPressed();
              },
            ),
          ],
        );
      },
    );
  }

  static showCustomConfirmDialog({
    @required BuildContext context,
    String title = 'Confirm',
    String message = 'Do you confirm?',
    Function onPressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
                if (onPressed != null) onPressed();
              },
            ),
          ],
        );
      },
    );
  }

  static verificationDialog(BuildContext context) {
    Dialogs.showCustomDialog(
      context: context,
      title: 'Verification',
      message: 'You need to verify your account to use this feature.',
    );
  }

  static forgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();
        var _email;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Password Reset',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    onSaved: (newValue) => _email = newValue,
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                    ),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                            ),
                          ),
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                _formKey.currentState.save();

                                var changeResult = await AuthService(
                                  context: context,
                                  showLoader: true,
                                ).resetPassword(_email);

                                if (changeResult.statusCode == 204) {
                                  Dialogs.showCustomDialog(
                                    context: context,
                                    title: 'Password Reset',
                                    message:
                                        'Password reset requested, check your email.',
                                    onPressed: () => Navigator.pop(context),
                                  );
                                } else {
                                  Dialogs.showCustomDialog(
                                    context: context,
                                    message: 'Invalid email.',
                                    onPressed: () => Navigator.pop(context),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "Submit",
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
        );
      },
    );
  }

  static emailChangeDialog(BuildContext context, Function setUserData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();
        var _email;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Change Email',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    onSaved: (newValue) => _email = newValue,
                                    decoration: InputDecoration(
                                      hintText: 'New email',
                                    ),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                            ),
                          ),
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                _formKey.currentState.save();

                                var changeResult = await AuthService(
                                  context: context,
                                  showLoader: true,
                                ).changeEmail(_email);

                                if (changeResult.statusCode == 200) {
                                  var token = changeResult.data['access_token'];
                                  await StorageService().writeVerified('0');
                                  await StorageService().writeUserData(
                                    token,
                                    _email,
                                  );
                                  setUserData();
                                  Dialogs.showCustomDialog(
                                    context: context,
                                    title: 'Email Changed',
                                    message: 'Your email has changed, ' +
                                        'you can now verify your account.',
                                    onPressed: () => Navigator.pop(context),
                                  );
                                } else {
                                  Dialogs.showCustomDialog(
                                    context: context,
                                    message: 'Invalid email.',
                                    onPressed: () => Navigator.pop(context),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "Save",
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
        );
      },
    );
  }

  static passwordChangeDialog(BuildContext context, Function setUserData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();
        var _oldPassword;
        var _password;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: SizedBox(
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Change Password',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    onSaved: (newValue) =>
                                        _oldPassword = newValue,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Old password',
                                    ),
                                    keyboardType: TextInputType.text,
                                    maxLength: 50,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'The password field is required';
                                      } else if (value.length < 6) {
                                        return 'The password field must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    onSaved: (newValue) => _password = newValue,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'New password',
                                    ),
                                    keyboardType: TextInputType.text,
                                    maxLength: 50,
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
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                            ),
                          ),
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                _formKey.currentState.save();

                                var changeResult = await AuthService(
                                  context: context,
                                  showLoader: true,
                                ).changePassword(_oldPassword, _password);

                                if (changeResult.statusCode == 200) {
                                  var token = changeResult.data['access_token'];
                                  await StorageService().writeAuthToken(token);

                                  Dialogs.showCustomDialog(
                                    context: context,
                                    title: 'Password Changed',
                                    message: 'Your password has changed, ',
                                    onPressed: () => Navigator.pop(context),
                                  );
                                } else {
                                  Dialogs.showCustomDialog(
                                    context: context,
                                    message: 'Invalid password.',
                                    onPressed: () => Navigator.pop(context),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "Save",
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
        );
      },
    );
  }
}
