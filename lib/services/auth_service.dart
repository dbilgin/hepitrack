import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hepitrack/utils/api.dart';
import 'package:hepitrack/utils/dialogs.dart';

class AuthService {
  BuildContext context;
  bool showLoader;
  AuthService({@required this.context, this.showLoader = false});

  Future<Response> register(String email, String password) async {
    try {
      if (showLoader) Dialogs.showLoading(context);
      var dio = API.getDio();
      Response response = await dio.post(
        'auth/register',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (showLoader) Navigator.pop(context);
      return response;
    } on DioError catch (error) {
      if (showLoader) Navigator.pop(context);
      return error.response;
    }
  }

  Future<Response> login(String email, String password) async {
    try {
      if (showLoader) Dialogs.showLoading(context);
      var dio = API.getDio();
      Response response = await dio.post(
        'auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (showLoader) Navigator.pop(context);
      return response;
    } on DioError catch (error) {
      if (showLoader) Navigator.pop(context);
      return error.response;
    }
  }

  Future<Response> resendVerification() async {
    try {
      var dio = API.getDio();
      Response response = await dio.get(
        'auth/resend_verification',
      );

      return response;
    } on DioError catch (error) {
      return error.response;
    }
  }

  Future<Response> changeEmail(String newEmail) async {
    try {
      var dio = API.getDio();
      Response response = await dio.post(
        'auth/change_email',
        data: {
          'new_email': newEmail,
        },
      );

      return response;
    } on DioError catch (error) {
      return error.response;
    }
  }

  Future<Response> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      var dio = API.getDio();
      Response response = await dio.post(
        'auth/change_password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      return response;
    } on DioError catch (error) {
      return error.response;
    }
  }

  Future<Response> deleteAccount() async {
    try {
      var dio = API.getDio();
      Response response = await dio.delete('auth/delete_account');

      return response;
    } on DioError catch (error) {
      return error.response;
    }
  }

  Future<Response> logOut() async {
    try {
      var dio = API.getDio();
      Response response = await dio.get('auth/log_out');

      return response;
    } on DioError catch (error) {
      return error.response;
    }
  }

  Future<Response> resetPassword(String email) async {
    try {
      var dio = API.getDio();
      Response response = await dio.post(
        'auth/reset_password_request',
        data: {
          'email': email,
        },
      );

      return response;
    } on DioError catch (error) {
      return error.response;
    }
  }
}
