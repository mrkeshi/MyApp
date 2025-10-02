// lib/features/auth/data/datasources/auth_remote.dart
import 'package:aria/features/auth/data/models/resend_request_code_dto.dart';
import 'package:aria/features/auth/data/models/verify_request_code_dto.dart';
import 'package:dio/dio.dart';
import 'package:aria/core/network/dio_client.dart';
import 'package:aria/features/auth/data/models/request_code_dto.dart';
import 'package:aria/features/auth/data/models/user_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRemoteDataSource {
  final DioClient client;
  AuthRemoteDataSource(this.client);

  Future<void> requestCode(RequestCodeDto dto) async {
    final res = await client.dio.post(
      '/api/v1/auth/request-code/',
      data: dto.toJson(),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/request-code/'),
        response: res,
        error: 'Unexpected status: ${res.statusCode}',
        type: DioExceptionType.badResponse,
      );
    }
  }

  Future<void> resendRequestCode(ResendRequestCodeDto dto) async {
    final res = await client.dio.post(
      '/api/v1/auth/request-code/',
      data: dto.toJson(),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/request-code/'),
        response: res,
        error: 'Unexpected status: ${res.statusCode}',
        type: DioExceptionType.badResponse,
      );
    }
  }

  // NOTE: برای سازگاری عقب‌رو؛ متد قبلی را نگه می‌داریم.
  Future<Map<String, dynamic>> VerifyCode(VerifyRequestCodeDto dto) async {
    return verifyCode(dto);
  }

  // نسخه‌ی استاندارد نام‌گذاری
  Future<Map<String, dynamic>> verifyCode(VerifyRequestCodeDto dto) async {
    final res = await client.dio.post(
      '/api/v1/auth/verify-code/',
      data: dto.toJson(),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/verify-code/'),
        response: res,
        error: 'Unexpected status: ${res.statusCode}',
        type: DioExceptionType.badResponse,
      );
    }

    return res.data as Map<String, dynamic>;
  }

  /// گرفتن پروفایل من /api/v1/me/ با استفاده از access_token از SharedPreferences
  Future<UserDto> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null || accessToken.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/me/'),
        error: 'No access token',
        type: DioExceptionType.unknown,
      );
    }

    final res = await client.dio.get(
      '/api/v1/me/',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    if (res.statusCode != 200) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/me/'),
        response: res,
        error: 'Unexpected status: ${res.statusCode}',
        type: DioExceptionType.badResponse,
      );
    }

    return UserDto.fromJson(res.data as Map<String, dynamic>);
  }


  Future<UserDto> patchMe({
    String? username,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    int? province,
    MultipartFile? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null || accessToken.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/me/'),
        error: 'No access token',
        type: DioExceptionType.unknown,
      );
    }

    final form = FormData.fromMap({
      if (username != null) 'username': username,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (province != null) 'province': province,
      if (profileImage != null) 'profile_image': profileImage,
    });

    final res = await client.dio.patch(
      '/api/v1/me/',
      data: form,
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        contentType: 'multipart/form-data',
      ),
    );

    if (res.statusCode != 200) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/me/'),
        response: res,
        error: 'Unexpected status: ${res.statusCode}',
        type: DioExceptionType.badResponse,
      );
    }

    return UserDto.fromJson(res.data as Map<String, dynamic>);
  }
}
