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

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'توکن دسترسی موجود نیست',
        type: DioExceptionType.unknown,
      );
    }
    return {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
  }

  Options _opts(Map<String, String> headers) => Options(headers: headers, validateStatus: (_) => true);

  Future<List<Attraction>> getTopAttractions(int provinceId) async {
    final headers = await _authHeaders();
    final res = await dio.get(
      '/api/v1/attractions/top-attractions/',
      queryParameters: {'province_id': provinceId},
      options: _opts(headers),
    );
    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data.map((e) => AttractionDto.fromJson(e as Map<String, dynamic>).toEntity()).toList();
    }
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/attractions/top-attractions/'),
      error: 'خطا در دریافت داده: ${res.statusCode}',
      type: DioExceptionType.badResponse,
      response: res,
    );
  }

  Future<List<Attraction>> getAttractions() async {
    final headers = await _authHeaders();
    final res = await dio.get(
      '/api/v1/attractions/',
      options: _opts(headers),
    );
    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data.map((e) => AttractionDto.fromJson(e as Map<String, dynamic>).toEntity()).toList();
    }
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/attractions/'),
      error: 'خطا در دریافت داده: ${res.statusCode}',
      type: DioExceptionType.badResponse,
      response: res,
    );
  }

  Future<AttractionDetail> getAttractionDetail(int id) async {
    final headers = await _authHeaders();
    final res = await dio.get(
      '/api/v1/attractions/$id/',
      options: _opts(headers),
    );
    if (res.statusCode == 200) {
      return AttractionDetailDto.fromJson(res.data as Map<String, dynamic>).toEntity();
    }
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/attractions/$id/'),
      error: 'خطا در دریافت داده: ${res.statusCode}',
      type: DioExceptionType.badResponse,
      response: res,
    );
  }

  Future<List<AttractionSearchResult>> searchAttractions(String query) async {
    final headers = await _authHeaders();
    final res = await dio.get(
      '/api/v1/attractions/search/',
      queryParameters: {'q': query},
      options: _opts(headers),
    );
    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data.map((e) => AttractionSearchResultDto.fromJson(e as Map<String, dynamic>).toEntity()).toList();
    }
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/attractions/search/'),
      error: 'خطا در دریافت داده: ${res.statusCode}',
      type: DioExceptionType.badResponse,
      response: res,
    );
  }

  Future<List<Attraction>> getTop10Attractions(int provinceId) async {
    final headers = await _authHeaders();
    final res = await dio.get(
      '/api/v1/attractions/top-10-attractions/',
      queryParameters: {'province_id': provinceId},
      options: _opts(headers),
    );
    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data.map((e) => AttractionDto.fromJson(e as Map<String, dynamic>).toEntity()).toList();
    }
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/attractions/top-10-attractions/'),
      error: 'خطا در دریافت داده: ${res.statusCode}',
      type: DioExceptionType.badResponse,
      response: res,
    );
  }

  Future<void> postMyReview({
    required int attractionId,
    required int rating,
    required String comment,
  }) async {
    final headers = await _authHeaders();
    final path = '/api/v1/attractions/$attractionId/reviews-my/';
    final res = await dio.post(
      path,
      data: {'rating': rating, 'comment': comment},
      options: _opts(headers),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return;
    }
    if (res.statusCode == 401) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'دسترسی نامعتبر (401). لطفاً دوباره وارد شوید.',
        type: DioExceptionType.badResponse,
        response: res,
      );
    }
    throw DioException(
      requestOptions: RequestOptions(path: path),
      error: 'خطا در ثبت نظر: ${res.statusCode}',
      type: DioExceptionType.badResponse,
      response: res,
    );
  }
}
