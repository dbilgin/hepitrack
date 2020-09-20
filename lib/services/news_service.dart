import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:hepitrack/utils/api.dart';

class NewsService {
  Future<Response> getNewsList(RemoteConfig _remoteConfig) async {
    String genericKey = _remoteConfig.getString('generic_api_key');
    if (genericKey == null || genericKey == "") {
      return Response(statusCode: 204);
    }

    try {
      var dio = API.getDio(isGeneric: true);
      Response response = await dio.get(
        'news/list',
        options: Options(
          headers: {'Authorization': 'token ' + genericKey},
        ),
      );
      return response;
    } on DioError catch (error) {
      return error.response;
    }
  }
}
