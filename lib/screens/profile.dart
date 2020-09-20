import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hepitrack/models/auth_status.dart';
import 'package:hepitrack/screens/register.dart';
import 'package:hepitrack/services/auth_service.dart';
import 'package:hepitrack/services/storage_service.dart';
import 'package:hepitrack/services/user_service.dart';
import 'package:hepitrack/utils/common.dart';
import 'package:hepitrack/utils/dialogs.dart';
import 'package:package_info/package_info.dart';

import 'login.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Color _barColor;
  final double _appBarHeight = 128;
  double _fabOffsetTop = 128;
  double _titlePadding = 16;
  bool _isFabVisible = true;
  Future<PackageInfo> _loadPackageInfo;
  ScrollController _scrollController;
  final String _platform = Platform.isAndroid
      ? 'Android'
      : Platform.isIOS ? 'iOS' : Platform.operatingSystem;

  AuthLocalStatus _isAuthenticated = AuthLocalStatus.none;
  Future<String> _email;
  bool _isVerified = true;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadPackageInfo = PackageInfo.fromPlatform();
    _setUserData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _setUserData() async {
    _email = StorageService().readEmail();
    _isVerified = (await StorageService().readVerified()) == '1';
    _setUserColor();
    _checkAuthentication();
  }

  _setUserColor() {
    Color currentColor = DynamicTheme.of(context).data.appBarTheme.color;
    setState(() {
      _barColor = currentColor.alpha == 0 ? Colors.white : currentColor;
    });
  }

  _checkAuthentication() async {
    var isAuthenticated = await StorageService().isAuthenticated();
    setState(() {
      _isAuthenticated = isAuthenticated
          ? AuthLocalStatus.authenticated
          : AuthLocalStatus.not_authenticated;
    });
  }

  _showColorDialog() {
    Color previousColor = _barColor;
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _barColor,
            onColorChanged: (value) => setState(() {
              _barColor = value;
            }),
            showLabel: true,
            pickerAreaHeightPercent: 0.5,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Reset'),
            onPressed: () async {
              var colorResponse = await UserService().updateColor(null);

              if (colorResponse.statusCode == 204) {
                StorageService().deleteUserColor();

                var currentBrightness = DynamicTheme.of(context).brightness;
                DynamicTheme.of(context).setThemeData(
                    Common.getThemeData(brightness: currentBrightness));
                setState(() {
                  _barColor = Colors.white;
                });

                Navigator.of(context).pop();
              } else {
                Dialogs.showCustomDialog(context: context);
              }
            },
          ),
          FlatButton(
            child: const Text('Cancel'),
            onPressed: () {
              setState(() => _barColor = previousColor);
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: const Text('Set Color'),
            onPressed: () async {
              var hexColor =
                  '#${(_barColor.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
              var colorResponse = await UserService().updateColor(hexColor);

              if (colorResponse.statusCode == 204) {
                StorageService().writeUserColor(_barColor);

                var currentBrightness = DynamicTheme.of(context).brightness;
                DynamicTheme.of(context).setThemeData(Common.getThemeData(
                    brightness: currentBrightness, appBarColor: _barColor));

                Navigator.of(context).pop();
              } else {
                Dialogs.showCustomDialog(context: context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final double offset = _scrollController.offset;
      final double delta = _appBarHeight - kToolbarHeight;
      bool thresholdReached = (_appBarHeight - offset) >
          kToolbarHeight + 48 * 0.3; // 48 -> size of FAB
      final double t = (offset / delta).clamp(0.0, 1.0);
      setState(() {
        _fabOffsetTop = _appBarHeight - offset;
        _titlePadding = Tween<double>(begin: 16, end: 64).transform(t);
        _isFabVisible = thresholdReached;
      });
    }
  }

  void _showSupportEmailSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: [
              new ListTile(
                title: Text('Send email?'),
              ),
              new ListTile(
                title: new Text('Yes'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final Email email = Email(
                    subject: 'Hepitrack Support',
                    recipients: ['support@omedacore.com'],
                    isHTML: false,
                  );
                  await FlutterEmailSender.send(email);
                },
              ),
              new ListTile(
                title: new Text('No'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _resendVerification() async {
    var resendResult = await AuthService(
      context: context,
      showLoader: true,
    ).resendVerification();

    if (resendResult.statusCode == 204) {
      Dialogs.showCustomDialog(
        context: context,
        title: 'Verification Email Sent',
        message: 'Check your inbox to verify your email address.',
      );
    } else {
      Dialogs.showCustomDialog(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: _barColor == null
                ? Theme.of(context).scaffoldBackgroundColor
                : _barColor,
            pinned: true,
            expandedHeight: _appBarHeight,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              titlePadding:
                  EdgeInsetsDirectional.only(start: _titlePadding, bottom: 0),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isAuthenticated == AuthLocalStatus.authenticated)
                      new FutureBuilder<String>(
                        future: _email, // async work
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (!snapshot.hasError && snapshot.hasData)
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.5,
                              ),
                              child: Text(
                                snapshot.data,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            );
                          else
                            return Container();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                if (!_isVerified &&
                    _isAuthenticated == AuthLocalStatus.authenticated)
                  Container(
                    margin: EdgeInsets.only(top: 24),
                    child: Material(
                      color: Colors.orange,
                      child: InkWell(
                        onTap: () => _resendVerification(),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.white,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Press here to resend verification email.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_isAuthenticated == AuthLocalStatus.not_authenticated)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                    ),
                    child: Text(
                      'User',
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                  ),
                if (_isAuthenticated == AuthLocalStatus.not_authenticated)
                  ListTile(
                    title: Text('Login'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    ),
                  ),
                if (_isAuthenticated == AuthLocalStatus.not_authenticated)
                  ListTile(
                    title: Text('Register'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    ),
                  ),
                if (_isAuthenticated == AuthLocalStatus.not_authenticated)
                  const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: Text(
                    'Settings',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.wb_sunny),
                  title: const Text('Dark mode'),
                  onTap: () {
                    Brightness newBrightness;

                    if (DynamicTheme.of(context).brightness == Brightness.dark)
                      newBrightness = Brightness.light;
                    else
                      newBrightness = Brightness.dark;

                    DynamicTheme.of(context).setBrightness(newBrightness);
                    DynamicTheme.of(context).setThemeData(Common.getThemeData(
                        brightness: newBrightness, appBarColor: _barColor));
                  },
                ),
                if (_isAuthenticated == AuthLocalStatus.authenticated)
                  Column(
                    children: [
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.alternate_email),
                        title: const Text('Change email'),
                        onTap: () {
                          if (!_isVerified) {
                            Dialogs.verificationDialog(context);
                          } else {
                            Dialogs.emailChangeDialog(context, _setUserData);
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.vpn_key),
                        title: const Text('Change password'),
                        onTap: () {
                          if (!_isVerified) {
                            Dialogs.verificationDialog(context);
                          } else {
                            Dialogs.passwordChangeDialog(context, _setUserData);
                          }
                        },
                      ),
                    ],
                  ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: Text(
                    'Help',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Support'),
                  onTap: () => _showSupportEmailSheet(),
                ),
                Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Privacy Policy'),
                  onTap: () {},
                ),
                const Divider(height: 1),
                FutureBuilder(
                  future: _loadPackageInfo,
                  builder: (_, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        snapshot.hasData
                            ? "${snapshot.data.appName} for $_platform v${snapshot.data.version} (${snapshot.data.buildNumber})"
                            : snapshot.hasError ? 'Error' : 'Loading...',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                if (_isAuthenticated == AuthLocalStatus.authenticated)
                  FlatButton(
                    onPressed: () {
                      Dialogs.showCustomConfirmDialog(
                        title: 'Are you sure?',
                        message: 'Do you really want to log out?',
                        context: context,
                        onPressed: () async {
                          await AuthService(context: context).logOut();
                          Common.cleanAndRestart(context);
                        },
                      );
                    },
                    child: Text(
                      'Log out',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                if (_isAuthenticated == AuthLocalStatus.authenticated)
                  FlatButton(
                    onPressed: () {
                      Dialogs.showCustomConfirmDialog(
                        title: 'Are you sure?',
                        message: 'Do you really want to delete your account?',
                        context: context,
                        onPressed: () async {
                          var deleteResponse =
                              await AuthService(context: context)
                                  .deleteAccount();

                          if (deleteResponse.statusCode == 204) {
                            Common.cleanAndRestart(context);
                          } else {
                            Dialogs.showCustomDialog(context: context);
                          }
                        },
                      );
                    },
                    child: Text(
                      'Delete account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).errorColor),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            top: _fabOffsetTop,
            right: 0,
            child: Visibility(
              visible: _isFabVisible,
              child: FloatingActionButton(
                child: const Icon(Icons.color_lens),
                onPressed: _showColorDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
