import 'package:aria/core/result/result.dart';
import 'package:aria/features/auth/domain/entities/user.dart';
import 'package:dio/dio.dart';

abstract class AuthRepository {
  Future<Result<void>> requestCode(String phone);
  Future<Result<void>> resendCode(String phone);
  Future<Result<void>> verifyCode(String phone, String code);

  Future<Result<User>> getMe();
  Future<Result<User>> updateMe({
    String? firstName,
    String? lastName,
    MultipartFile? profileImage,
  });


  Future<Result<void>> logout();
}
