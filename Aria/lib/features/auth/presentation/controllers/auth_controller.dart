// lib/features/auth/presentation/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:aria/core/result/result.dart';
import 'package:aria/core/utils/validators.dart';
import 'package:aria/features/auth/domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repo);

  final AuthRepository _repo;

  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  String? errorText;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<bool> sendCode() async {
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

    final res = await _repo.requestCode(normalized);

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
}
