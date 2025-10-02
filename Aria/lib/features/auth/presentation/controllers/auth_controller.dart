import 'package:flutter/material.dart';
import 'package:aria/core/result/result.dart';
import 'package:aria/core/utils/validators.dart';
import 'package:aria/features/auth/domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repo);

  final AuthRepository _repo;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  String? errorText;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<bool> sendCode({bool is_resend = false}) async {
    final raw = phoneController.text;
    final normalized = Validators.normalizePhone(raw);

    errorText = Validators.phoneError(normalized);
    if (errorText != null) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorText = null;
    notifyListeners();

    Result<void>? res;

    if (is_resend) {
      res = await _repo.resendCode(normalized);
    } else {
      res = await _repo.requestCode(normalized);
    }

    isLoading = false;

    final ok = res.when(
      ok: (_) => true,
      err: (f) {
        errorText = f.message;
        return false;
      },
    );

    notifyListeners();
    return ok;
  }

  Future<bool> verifyCode() async {
    try {
      isLoading = true;
      notifyListeners();

      final otp = otpController.text;
      final res = await _repo.verifyCode(phoneController.text, otp);

      isLoading = false;
      final success = res.when(
        ok: (_) => true,
        err: (f) {
          errorText = f.message;
          return false;
        },
      );

      notifyListeners();
      return success;
    } catch (e) {
      errorText = "مشکل در اتصال به شبکه.";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
