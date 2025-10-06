import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/province_dto.dart';

class ProvinceRemote {
  final Dio dio;
  ProvinceRemote(this.dio);

  String? _extractValidationMessage(dynamic data) {
    if (data == null) return null;
    if (data is String && data.trim().isNotEmpty) return data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is String && first.trim().isNotEmpty) return first;
      }
      for (final v in data.values) {
        if (v is List && v.isNotEmpty && v.first is String) {
          final first = (v.first as String).trim();
          if (first.isNotEmpty) return first;
        } else if (v is String && v.trim().isNotEmpty) {
          return v;
        }
      }
    }
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is String && first.trim().isNotEmpty) return first;
    }
    return null;
  }

  Future<void> changeProvince(int provinceId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken == null || accessToken.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/me/change-province/'),
        error: 'توکن دسترسی موجود نیست',
        type: DioExceptionType.unknown,
      );
    }

    final res = await dio.post(
      '/api/v1/me/change-province/',
      data: {'province_id': provinceId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200 || res.statusCode == 204) return;

    final msg = _extractValidationMessage(res.data) ?? 'خطای نامشخص از سرور';
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: msg,
      type: DioExceptionType.badResponse,
    );
  }

  Future<ProvinceDto> getProvinceDetail(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken == null || accessToken.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/provinces/$id/'),
        error: 'توکن دسترسی موجود نیست',
        type: DioExceptionType.unknown,
      );
    }

    final res = await dio.get(
      '/api/v1/provinces/$id/',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200) {
      return ProvinceDto.fromJson(res.data as Map<String, dynamic>);
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
