import 'package:dio/dio.dart';
import 'package:hepitrack/utils/api.dart';

class UserService {
  Future<Response> data() async {
    try {
      var dio = API.getDio();
      Response response = await dio.get(
        'user/data',
      );

      return response;
    } on DioError catch (error) {
      return error.response;
    }
  }

  Future<Response> updateColor(String color) async {
    try {
      var dio = API.getDio();
      Response response = await dio.patch(
        'user/color',
        data: {
          'color': color,
        },
      );

      return response;
    } on DioError catch (error) {
      return error.response;
    }
  }

  Future<Response> addTrack(Map<String, Object> trackData) async {
    try {
      var dio = API.getDio();
      Response response = await dio.post('track/save', data: trackData);

      return response;
    } on DioError catch (error) {
      return error.response;
    }
  }

  Future<Response> getAllTracks() async {
    try {
      var dio = API.getDio();
      Response response = await dio.get('track/all');

      return response;
    } on DioError catch (error) {
      return error.response;
    }
  }
}
