// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:aria/core/error/failure.dart';
import 'package:aria/core/result/result.dart';
import 'package:aria/features/auth/data/datasources/auth_remote.dart';
import 'package:aria/features/auth/data/models/request_code_dto.dart';
import 'package:aria/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<Result<void>> requestCode(String phone) async {
    try {
      final dto = RequestCodeDto(phoneNumber: phone);
      await remote.requestCode(dto);
      return const Ok(null);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['detail']?.toString() ?? 'خطای شبکه')
          : 'خطای شبکه';
      return Err(Failure(msg, code: e.response?.statusCode));
    } catch (_) {
      return Err(Failure('مشکل غیرمنتظره، دوباره تلاش کنید.'));
    }
  }
  @override Future<Result<void>> verifyCode(String phone, String code) {
    // TODO: implement verifyCode
    throw UnimplementedError();
  }
  @override
  Future<Result<void>> resendCode(String phone) {
    // TODO: implement resendCode
    throw UnimplementedError();
  }
}
