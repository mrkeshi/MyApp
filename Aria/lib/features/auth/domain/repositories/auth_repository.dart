import 'package:aria/core/result/result.dart';

abstract class AuthRepository {
  Future<Result<void>> requestCode(String phone);
  Future<Result<void>> resendCode(String phone);
  Future<Result<void>> verifyCode(String phone, String code);
}