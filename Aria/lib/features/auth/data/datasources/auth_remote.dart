// lib/features/auth/data/datasources/auth_remote.dart
import 'package:dio/dio.dart';
import 'package:aria/core/network/dio_client.dart';
import 'package:aria/features/auth/data/models/request_code_dto.dart';

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
}
