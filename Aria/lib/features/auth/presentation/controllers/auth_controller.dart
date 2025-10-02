// lib/features/auth/presentation/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:aria/core/result/result.dart';
import 'package:aria/core/utils/validators.dart';
import 'package:aria/features/auth/domain/repositories/auth_repository.dart';
import 'package:aria/features/auth/domain/entities/user.dart';
import 'package:dio/dio.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repo);

  final AuthRepository _repo;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isLoading = false;
  String? errorText;

  User? currentUser;

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
      errorText = null;
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
    } catch (_) {
      errorText = "مشکل در اتصال به شبکه.";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadMe() async {
    try {
      isLoading = true;
      errorText = null;
      notifyListeners();

      final result = await _repo.getMe();

      isLoading = false;
      final ok = result.when(
        ok: (user) {
          currentUser = user;
          return true;
        },
        err: (f) {
          errorText = f.message;
          currentUser = null;
          return false;
        },
      );

      notifyListeners();
      return ok;
    } catch (_) {
      isLoading = false;
      errorText = "مشکل در دریافت پروفایل.";
      currentUser = null;
      notifyListeners();
      return false;
    }
  }

  /// فقط first_name, last_name, profile_image را آپدیت کن
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    MultipartFile? profileImage,
  }) async {
    try {
      isLoading = true;
      errorText = null;
      notifyListeners();

      final result = await _repo.updateMe(
        firstName: firstName,
        lastName: lastName,
        profileImage: profileImage,
      );

      isLoading = false;
      final ok = result.when(
        ok: (user) {
          currentUser = user;
          return true;
        },
        err: (f) {
          errorText = f.message;
          return false;
        },
      );

      notifyListeners();
      return ok;
    } catch (_) {
      isLoading = false;
      errorText = "مشکل در به‌روزرسانی پروفایل.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      isLoading = true;
      errorText = null;
      notifyListeners();

      final res = await _repo.logout();

      isLoading = false;
      final ok = res.when(
        ok: (_) {
          currentUser = null;
          otpController.clear();
          return true;
        },
        err: (f) {
          errorText = f.message;
          return false;
        },
      );

      notifyListeners();
      return ok;
    } catch (_) {
      isLoading = false;
      errorText = "خروج ناموفق.";
      notifyListeners();
      return false;
    }
  }

  Future<String?> verifyThenDecideRoute() async {
    final ok = await verifyCode();
    if (!ok) return null;

    final meOk = await loadMe();
    if (!meOk || currentUser == null) return null;

    final hasLastName =
    (currentUser!.lastName != null && currentUser!.lastName!.trim().isNotEmpty);

    return hasLastName ? '/home' : '/edit-profile';
  }
}
