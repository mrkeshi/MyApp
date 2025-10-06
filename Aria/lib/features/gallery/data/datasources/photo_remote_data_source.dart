import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo_model.dart';

class PhotoRemoteDataSource {
  final Dio dio;
  PhotoRemoteDataSource(this.dio);

  String? _extractValidationMessage(dynamic data) {
    if (data == null) return null;
    if (data is String && data.trim().isNotEmpty) return data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail;
      if (detail is List && detail.isNotEmpty && detail.first is String) {
        final s = (detail.first as String).trim();
        if (s.isNotEmpty) return s;
      }
      for (final v in data.values) {
        if (v is List && v.isNotEmpty && v.first is String) {
          final s = (v.first as String).trim();
          if (s.isNotEmpty) return s;
        } else if (v is String && v.trim().isNotEmpty) {
          return v.trim();
        }
      }
    }
    if (data is List && data.isNotEmpty && data.first is String) {
      final s = (data.first as String).trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  Future<List<PhotoModel>> fetchPhotos(int provinceId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken == null || accessToken.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/attractions/$provinceId/photos/'),
        error: 'توکن دسترسی موجود نیست',
        type: DioExceptionType.unknown,
      );
    }

    final res = await dio.get(
      '/api/v1/attractions/$provinceId/photos/',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200) {
      final data = res.data;
      if (data is List) {
        return data.map((e) => PhotoModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      final list = (data['results'] ?? data['items'] ?? data['data'] ?? []) as List;
      return list.map((e) => PhotoModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    final msg = _extractValidationMessage(res.data) ?? 'خطای نامشخص از سرور';
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: msg,
      type: DioExceptionType.badResponse,
    );
  }
}
