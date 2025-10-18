import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark_dto.dart';

class BookmarkRemoteDataSource {
  final Dio dio;
  BookmarkRemoteDataSource(this.dio);

  Future<bool> toggle({required String type, required int id}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final res = await dio.post(
      '/api/v1/bookmarks/toggle/',
      data: {'type': type, 'id': id},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200 && res.data is Map && res.data['bookmarked'] is bool) {
      return res.data['bookmarked'] as bool;
    }
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/bookmarks/toggle/'),
      error: 'Bookmark toggle failed: ${res.statusCode}',
      type: DioExceptionType.unknown,
    );
  }

  Future<Set<int>> listIds({required String type}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final res = await dio.get(
      '/api/v1/bookmarks/',
      queryParameters: {'type': type, 'fields': 'id'},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200 && res.data is List) {
      final list = res.data as List;
      return list
          .where((e) => e is Map && e['id'] != null)
          .map<int>((e) => (e['id'] as num).toInt())
          .toSet();
    }
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/bookmarks/'),
      error: 'Bookmark listIds failed: ${res.statusCode}',
      type: DioExceptionType.unknown,
    );
  }

  Future<List<BookmarkDto>> list({required String type}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final res = await dio.get(
      '/api/v1/bookmarks/',
      queryParameters: {'type': type},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode == 200 && res.data is List) {
      final list = res.data as List;
      return list
          .where((e) => e is Map<String, dynamic>)
          .map<BookmarkDto>((e) => BookmarkDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/bookmarks/'),
      error: 'Bookmark list failed: ${res.statusCode}',
      type: DioExceptionType.unknown,
    );
  }
}
