import 'package:dio/dio.dart';
import 'package:hepitrack/services/storage_service.dart';

class API {
  static Dio getDio({isGeneric = false}) {
    var _dio = Dio();
    _dio.options.baseUrl = 'https://api.hepitrack.com/';
    // _dio.options.baseUrl = 'http://10.0.2.2:5000/';

    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      options.headers.addAll({'Content-Type': 'application/json'});

      if (!isGeneric) {
        var authToken = await StorageService().readAuthToken();
        if (authToken != null) {
          options.headers.addAll({'Authorization': 'token ' + authToken});
        }
      }
      return options; //continue
    }));

    return _dio;
  }
}
