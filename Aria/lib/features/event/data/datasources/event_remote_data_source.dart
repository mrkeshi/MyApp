import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_detail.dart';
import '../models/event_dto.dart';
import '../models/event_detail_dto.dart';

class EventRemoteDataSource {
  final Dio dio;
  EventRemoteDataSource(this.dio);

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

  Future<List<Event>> getEvents() async {
    final headers = await _authHeaders();
    final path = '/api/v1/events/';
    final res = await dio.get(path, options: _opts(headers));
    if (res.statusCode == 200) {
      final data = res.data as List<dynamic>;
      return data.map((e) => EventDto.fromJson(e as Map<String, dynamic>).toEntity()).toList();
    }
    throw DioException(
      requestOptions: RequestOptions(path: path),
      error: 'خطا در دریافت داده: ${res.statusCode}',
      type: DioExceptionType.badResponse,
      response: res,
    );
  }

  Future<EventDetail> getEventDetail(int id) async {
    final headers = await _authHeaders();
    final path = '/api/v1/events/$id/';
    final res = await dio.get(path, options: _opts(headers));
    if (res.statusCode == 200) {
      return EventDetailDto.fromJson(res.data as Map<String, dynamic>).toEntity();
    }
    throw DioException(
      requestOptions: RequestOptions(path: path),
      error: 'خطا در دریافت داده: ${res.statusCode}',
      type: DioExceptionType.badResponse,
      response: res,
    );
  }

  Future<void> upsertMyReview({required int eventId, required int rating, required String comment}) async {
    final headers = await _authHeaders();
    final path = '/api/v1/events/$eventId/reviews/my/';
    final res = await dio.post(path, data: {'rating': rating, 'comment': comment}, options: _opts(headers));
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
