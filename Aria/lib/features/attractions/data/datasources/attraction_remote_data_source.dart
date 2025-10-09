import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/attraction.dart';
import '../models/attraction_dto.dart';


class AttractionRemoteDataSource {
  final Dio dio;

  AttractionRemoteDataSource(this.dio);

  Future<List<Attraction>> getTopAttractions(int provinceId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null || accessToken.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/attractions/province/$provinceId/top-attractions/'),
        error: 'توکن دسترسی موجود نیست',
        type: DioExceptionType.unknown,
      );
    }

    final res = await dio.get(
      '/api/v1/attractions/top-attractions/',
      queryParameters: {
        'province_id': provinceId,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      final attractions = data
          .map((e) => AttractionDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      return attractions;
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/top-attractions/'),
        error: 'خطا در دریافت داده: ${res.statusCode}',
        type: DioExceptionType.unknown,
      );
    }


    final msg = res.data['detail'] ?? 'خطای نامشخص از سرور';
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: msg,
      type: DioExceptionType.badResponse,
    );
  }
}
