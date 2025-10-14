import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/attraction.dart';
import '../../domain/entities/attraction_detail.dart';
import '../../domain/entities/attraction_search_result.dart';
import '../models/attraction_dto.dart';
import '../models/attraction_detail_dto.dart';
import '../models/attraction_search_result_dto.dart';

class AttractionRemoteDataSource {
  final Dio dio;

  AttractionRemoteDataSource(this.dio);

  Future<List<Attraction>> getTopAttractions(int provinceId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null || accessToken.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/top-attractions/'),
        error: 'توکن دسترسی موجود نیست',
        type: DioExceptionType.unknown,
      );
    }

    final res = await dio.get(
      '/api/v1/attractions/top-attractions/',
      queryParameters: {'province_id': provinceId},
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data
          .map((e) => AttractionDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/top-attractions/'),
        error: 'خطا در دریافت داده: ${res.statusCode}',
        type: DioExceptionType.unknown,
      );
    }
  }

  Future<List<Attraction>> getAttractions() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    final res = await dio.get(
      '/api/v1/attractions/',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data
          .map((e) => AttractionDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/'),
        error: 'خطا در دریافت داده: ${res.statusCode}',
        type: DioExceptionType.unknown,
      );
    }
  }

  Future<AttractionDetail> getAttractionDetail(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    final res = await dio.get(
      '/api/v1/attractions/$id/',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200) {
      return AttractionDetailDto.fromJson(res.data as Map<String, dynamic>).toEntity();
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/$id/'),
        error: 'خطا در دریافت داده: ${res.statusCode}',
        type: DioExceptionType.unknown,
      );
    }
  }

  Future<List<AttractionSearchResult>> searchAttractions(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    final res = await dio.get(
      '/api/v1/attractions/search/',
      queryParameters: {'q': query},
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data
          .map((e) => AttractionSearchResultDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/search/'),
        error: 'خطا در دریافت داده: ${res.statusCode}',
        type: DioExceptionType.unknown,
      );
    }
  }

  Future<List<Attraction>> getTop10Attractions(int provinceId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null || accessToken.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/top-10-attractions/'),
        error: 'توکن دسترسی موجود نیست',
        type: DioExceptionType.unknown,
      );
    }

    final res = await dio.get(
      '/api/v1/attractions/top-10-attractions/',
      queryParameters: {'province_id': provinceId},
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data
          .map((e) => AttractionDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/top-10-attractions/'),
        error: 'خطا در دریافت داده: ${res.statusCode}',
        type: DioExceptionType.unknown,
      );
    }
  }

  Future<void> postMyReview({
    required int attractionId,
    required int rating,
    required String comment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null || accessToken.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/$attractionId/reviews/my/'),
        error: 'توکن دسترسی موجود نیست',
        type: DioExceptionType.unknown,
      );
    }

    final res = await dio.post(
      '/api/v1/attractions/$attractionId/reviews/my/',
      data: {'rating': rating, 'comment': comment},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return;
    } else if (res.statusCode == 401) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/$attractionId/reviews/my/'),
        error: 'دسترسی نامعتبر (401). لطفاً دوباره وارد شوید.',
        type: DioExceptionType.badResponse,
        response: res,
      );
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/$attractionId/reviews/my/'),
        error: 'خطا در ثبت نظر: ${res.statusCode}',
        type: DioExceptionType.badResponse,
        response: res,
      );
    }
  }
}
