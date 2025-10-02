// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:aria/core/error/failure.dart';
import 'package:aria/core/result/result.dart';
import 'package:aria/features/auth/data/datasources/auth_remote.dart';
import 'package:aria/features/auth/data/models/request_code_dto.dart';
import 'package:aria/features/auth/data/models/user_dto.dart';
import 'package:aria/features/auth/domain/entities/user.dart';
import 'package:aria/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/resend_request_code_dto.dart';
import '../models/verify_request_code_dto.dart';

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

  @override
  Future<Result<void>> verifyCode(String phone, String code) async {
    try {
      final verifyDto = VerifyRequestCodeDto(phoneNumber: phone, code: code);


      final res = await remote.verifyCode(verifyDto);

      final accessToken = res['access_token'];
      final refreshToken = res['refresh_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);

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

  @override
  Future<Result<void>> resendCode(String phone) async {
    try {
      final resendDto = ResendRequestCodeDto(phoneNumber: phone);
      await remote.resendRequestCode(resendDto);
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


  @override
  Future<Result<User>> getMe() async {
    try {
      final UserDto dto = await remote.getMe();
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['detail']?.toString() ?? 'خطای احراز هویت/شبکه')
          : 'خطای احراز هویت/شبکه';
      return Err(Failure(msg, code: e.response?.statusCode));
    } catch (_) {
      return Err(Failure('مشکل غیرمنتظره، دوباره تلاش کنید.'));
    }
  }
}
