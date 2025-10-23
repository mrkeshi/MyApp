import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aria/core/result/result.dart';
import 'package:aria/core/utils/validators.dart';
import 'package:aria/features/auth/domain/repositories/auth_repository.dart';
import 'package:aria/features/auth/domain/entities/user.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aria/features/province/domain/repositories/province_repository.dart';
import 'package:aria/core/network/dio_client.dart';
import '../../../province/presentation/controller/province_controller.dart';

enum NextStep { welcome, chooseProvince, editProfile, home }

class AuthController extends ChangeNotifier {
  AuthController(
    this._repo, {
    required ProvinceController provinceController,
    ProvinceRepository? provinceRepo,
  }) : _provinceController = provinceController,
       _provinceRepo = provinceRepo;

  final AuthRepository _repo;
  final ProvinceRepository? _provinceRepo;
  final ProvinceController _provinceController;

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

      if (currentUser?.province != null) {
        await _provinceController.ensureProvinceFromUser(currentUser!.province);
      }

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
        (currentUser!.lastName != null &&
            currentUser!.lastName!.trim().isNotEmpty);
    return hasLastName ? '/home' : '/edit-profile';
  }

  int? _effectiveProvinceId(User u) {
    final p = u.province;
    if (p != null && p != 0) return p;
    return null;
  }

  Future<NextStep> resolveNextStep() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString('access_token');
    final refresh = prefs.getString('refresh_token');

    Future<NextStep> afterAuth() async {
      final ok = await loadMe();
      if (!ok || currentUser == null) return NextStep.welcome;
      final u = currentUser!;
      final isProfileIncomplete =
          (u.firstName == null || u.firstName!.trim().isEmpty) ||
          (u.lastName == null || u.lastName!.trim().isEmpty);
      if (isProfileIncomplete) return NextStep.editProfile;
      final pid = _effectiveProvinceId(u);
      if (pid == null) return NextStep.chooseProvince;
      try {
        await _provinceController.fetchProvinceDetail(pid);
      } catch (_) {}
      return NextStep.home;
    }

    if (access != null && access.isNotEmpty && !_isJwtExpired(access)) {
      return afterAuth();
    }
    if (refresh != null && refresh.isNotEmpty) {
      final refreshed = await _tryRefreshWithPrefs(prefs, refresh);
      return refreshed ? await afterAuth() : NextStep.welcome;
    }
    return NextStep.welcome;
  }

  bool _isJwtExpired(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return true;
      String payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decoded =
          json.decode(utf8.decode(base64.decode(payload)))
              as Map<String, dynamic>;
      final exp = (decoded['exp'] as num?)?.toInt();
      if (exp == null) return true;
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp <= nowSec;
    } catch (_) {
      return true;
    }
  }

  Future<bool> _tryRefreshWithPrefs(
    SharedPreferences prefs,
    String refreshToken,
  ) async {
    try {
      final baseUrl = const String.fromEnvironment(
        'API_BASE',
        defaultValue: 'https://aria.penvis.ir',
      );
      final dio = DioClient(baseUrl: baseUrl).dio;
      final res = await dio.post(
        '/api/v1/auth/refresh/',
        data: {'refresh': refreshToken},
        options: Options(contentType: Headers.jsonContentType),
      );
      if (res.statusCode == 200 && res.data is Map) {
        final map = res.data as Map;
        final newAccess = (map['access'] ?? map['access_token']) as String?;
        final newRefresh = (map['refresh'] ?? map['refresh_token']) as String?;
        if (newAccess != null && newAccess.isNotEmpty) {
          await prefs.setString('access_token', newAccess);
        }
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await prefs.setString('refresh_token', newRefresh);
        }
        return newAccess != null && newAccess.isNotEmpty;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
