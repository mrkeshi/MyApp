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

  Future<Map<String, dynamic>> VerifyCode(VerifyRequestCodeDto dto) async {
    return verifyCode(dto);
  }

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
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
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
    String? firstName,
    String? lastName,
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

    final data = <String, dynamic>{};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (profileImage != null) data['profile_image'] = profileImage;

    final options = Options(
      headers: {'Authorization': 'Bearer $accessToken'},
      contentType: profileImage != null ? 'multipart/form-data' : 'application/json',
    );

    final res = await client.dio.patch(
      '/api/v1/me/',
      data: profileImage != null ? FormData.fromMap(data) : data,
      options: options,
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
