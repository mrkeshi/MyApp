import 'package:flutter/services.dart';

class PersianDigitsFormatter extends TextInputFormatter {
  static const _en = ['0','1','2','3','4','5','6','7','8','9'];
  static const _fa = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
  static const _ar = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];

  String _toFa(String input) {
    var out = input;
    for (var i = 0; i < 10; i++) {
      out = out.replaceAll(_en[i], _fa[i]);
      out = out.replaceAll(_ar[i], _fa[i]);
    }
    return out;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final faText = _toFa(newValue.text);
    // کرسر را تا جای ممکن نگه می‌داریم
    final base = faText.length;
    return TextEditingValue(
      text: faText,
      selection: TextSelection.collapsed(offset: base),
      composing: TextRange.empty,
    );
  }
}
