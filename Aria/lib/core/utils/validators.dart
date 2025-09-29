// lib/core/utils/validators.dart
class Validators {
  static String fa2enDigits(String input) {
    const fa = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
    const ar = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    for (var i = 0; i < 10; i++) {
      input = input.replaceAll(fa[i], '$i').replaceAll(ar[i], '$i');
    }
    return input;
  }

  static String normalizePhone(String input) {
    var v = fa2enDigits(input);
    v = v.replaceAll(RegExp(r'[\s\-_]'), '');
    return v;
  }

  static String? phoneError(String input) {
    final v = normalizePhone(input);
    if (v.isEmpty) return 'لطفاً شماره موبایل را وارد کنید';
    final regex = RegExp(r'^09\d{9}$');
    if (!regex.hasMatch(v)) return 'شماره موبایل معتبر نیست';
    return null;
  }

  static String? otpError(String input, {int min = 4, int max = 6}) {
    final v = fa2enDigits(input);
    final re = RegExp('^\\d{$min,$max}\$');
    if (!re.hasMatch(v)) return 'کد تأیید نامعتبر است';
    return null;
  }
}
