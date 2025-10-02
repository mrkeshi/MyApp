import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:aria/features/auth/presentation/controllers/auth_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/styles/colors.dart';
import '../../../../shared/widgets/primary_button.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  const OtpPage({Key? key, required this.phone}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  Timer? _ticker;
  int _secondsLeft = 0;
  static const double otpSize = 64;
  bool _otpComplete = false;
  String? _serverMessage;

  bool get _cooldownActive => _secondsLeft > 0;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(_onFieldChanged);
      _controllers[i].addListener(_onFieldChanged);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = Provider.of<AuthController>(context, listen: false);
      c.addListener(() {
        final msg = c.errorText;
        if (msg != null && msg.trim().isNotEmpty) {
          _showErrorSnack(msg);
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final authController = mounted ? Provider.of<AuthController>(context, listen: false) : null;
    final filled = _controllers.every((c) => c.text.isNotEmpty);
    final code = _otp;
    setState(() => _otpComplete = filled);
    if (authController != null) {
      authController.otpController.text = code;
    }
  }

  void _startCooldown(int seconds) {
    _ticker?.cancel();
    setState(() => _secondsLeft = seconds);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  String _mmss(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString();
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    const fa = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
    String faNum(String x) => x.split('').map((ch) {
      final i = '0123456789'.indexOf(ch);
      return i == -1 ? ch : fa[i];
    }).join();
    return faNum('$m:$s');
  }

  String _extractErrorMessage(Object e) {
    final raw = e.toString().trim();

    if (raw.startsWith('[') && raw.endsWith(']')) {
      var inner = raw.substring(1, raw.length - 1).trim();
      if ((inner.startsWith('"') && inner.endsWith('"')) ||
          (inner.startsWith("'") && inner.endsWith("'"))) {
        inner = inner.substring(1, inner.length - 1);
      }
      if (inner.isNotEmpty) return inner;
    }

    try {
      final data = jsonDecode(raw);
      if (data is String && data.trim().isNotEmpty) return data.trim();
      if (data is List) {
        for (final v in data) {
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
      }
      if (data is Map) {
        if (data['detail'] is String && (data['detail'] as String).trim().isNotEmpty) {
          return (data['detail'] as String).trim();
        }
        if (data['detail'] is List && (data['detail'] as List).isNotEmpty) {
          final v = (data['detail'] as List).first;
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
        const keys = ['code', 'phone_number', 'non_field_errors', 'error'];
        for (final k in keys) {
          final v = data[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
          if (v is List && v.isNotEmpty && v.first is String) {
            final s = (v.first as String).trim();
            if (s.isNotEmpty) return s;
          }
        }
        for (final v in data.values) {
          if (v is String && v.trim().isNotEmpty) return v.trim();
          if (v is List && v.isNotEmpty && v.first is String) {
            final s = (v.first as String).trim();
            if (s.isNotEmpty) return s;
          }
        }
      }
    } catch (_) {}

    final m1 = RegExp(r'"detail"\s*:\s*"([^"]+)"').firstMatch(raw);
    if (m1 != null) return m1.group(1)!.trim();

    final m2 = RegExp(r'\[\s*"([^"]+)"\s*\]').firstMatch(raw);
    if (m2 != null) return m2.group(1)!.trim();

    final m3 = RegExp(r"\[\s*'([^']+)'\s*\]").firstMatch(raw);
    if (m3 != null) return m3.group(1)!.trim();

    return 'خطا در پردازش درخواست. لطفاً دوباره تلاش کنید.';
  }


  void _showErrorSnack(String message) {
    if (!mounted) return;
    final snack = SnackBar(
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          textAlign: TextAlign.start,
        ),
      ),
      backgroundColor: AppColors.redPrimary,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(snack);
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final primary = Theme.of(context).primaryColor;

    Color borderColorFor(int index) {
      final hasFocus = _focusNodes[index].hasFocus;
      final hasText = _controllers[index].text.isNotEmpty;
      return (hasFocus || hasText) ? primary : AppColors.grayBlack.withOpacity(0.6);
    }

    final borderRadius = BorderRadius.circular(12);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/svg/back_arrow.svg', color: primary, width: 20, height: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'وارد کردن کد',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'لطفاً کد ارسال شده به شماره ${widget.phone} را وارد نمایید.',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                wordSpacing: -3,
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 40),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: primary,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]')),
                        PersianDigitsFormatter(),
                      ],
                      decoration: InputDecoration(
                        counterText: "",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColorFor(index), width: 2),
                          borderRadius: borderRadius,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primary, width: 2),
                          borderRadius: borderRadius,
                        ),
                        fillColor: AppColors.grayBlack,
                        filled: true,
                      ),
                      onChanged: (value) {
                        if (value.runes.length > 1) {
                          final firstChar = String.fromCharCode(value.runes.first);
                          _controllers[index].text = firstChar;
                          _controllers[index].selection = const TextSelection.collapsed(offset: 1);
                        }
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        _onFieldChanged();
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'customy'),
                children: [
                  const TextSpan(text: 'کد را دریافت نکرده‌اید؟ '),
                  TextSpan(
                    text: 'ارسال مجدد کد',
                    style: TextStyle(
                      color: _cooldownActive ? Colors.white38 : primary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: (TapGestureRecognizer()
                      ..onTap = _cooldownActive
                          ? null
                          : () async {
                        try {
                          final ok = await Provider.of<AuthController>(context, listen: false)
                              .sendCode(is_resend: true);
                          if (!mounted) return;
                          if (ok) {
                            _startCooldown(60);
                          } else {
                            final c = Provider.of<AuthController>(context, listen: false);
                            if (c.errorText != null && c.errorText!.trim().isNotEmpty) {
                              _showErrorSnack(_extractErrorMessage(c.errorText!));
                            }
                          }
                        } catch (e) {
                          if (!mounted) return;
                          _showErrorSnack(_extractErrorMessage(e));
                        }
                      }),
                  ),
                ],
              ),
            ),
            if (_serverMessage != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _serverMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            if (_cooldownActive) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'تا دریافت مجدد کد',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _mmss(_secondsLeft),
                    style: TextStyle(
                      color: primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Transform.translate(
                    offset: const Offset(0, -2),
                    child: const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 18,
                    ),
                  )
                ],
              )
            ],
            const Spacer(),
            PrimaryButton(
              text: authController.isLoading ? '...' : 'بررسی کد',
              backgroundColor: _otpComplete ? primary : Colors.black,
              onPressed: (!_otpComplete || authController.isLoading)
                  ? null
                  : () async {
                try {
                  final success = await authController.verifyCode();
                  if (!mounted) return;
                  if (success) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    final msg = authController.errorText ?? 'کد نامعتبر است.';
                    _showErrorSnack(_extractErrorMessage(msg));
                  }
                } catch (e) {
                  if (!mounted) return;
                  _showErrorSnack(_extractErrorMessage(e));
                }
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
