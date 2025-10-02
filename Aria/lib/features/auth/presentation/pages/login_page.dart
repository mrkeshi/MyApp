import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:aria/shared/styles/colors.dart';
import 'package:aria/shared/widgets/primary_button.dart';
import 'package:aria/core/utils/formatters.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/login.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
                const SizedBox(height: 24),
                Text(
                  'ثبت نام / ورود',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'شماره موبایل خود را وارد کنید تا کد برایتان ارسال شود.',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<AuthController>(builder: (context, c, _) {
                  void _onPhoneNumberChanged(String value) {
                    setState(() {}); 
                  }

                  c.phoneController.addListener(() {
                    _onPhoneNumberChanged(c.phoneController.text);
                  });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: c.phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\u06F0-\u06F9\u0660-\u0669]')),
                          LengthLimitingTextInputFormatter(11),
                          PersianDigitsFormatter(),
                        ],
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          hintText: '****۰۹۹۰۷۸۸',
                          hintTextDirection: TextDirection.rtl,
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: const Color(0xFF1B1B1B),
                          hintStyle: const TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Colors.white24, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Colors.white24, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: AppColors.redPrimary, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: AppColors.redPrimary, width: 2),
                          ),
                          errorText: c.errorText,
                          errorStyle: TextStyle(
                            color: AppColors.redPrimary,
                            fontSize: 12,
                            height: 1.9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                          errorMaxLines: 2,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        child: PrimaryButton(
                          text: c.isLoading ? 'در حال ارسال…' : 'ارسال کد',
                          onPressed: c.phoneController.text.length == 11 && !c.isLoading
                              ? () {
                            if (c.isLoading) return;
                            c.sendCode().then((ok) {
                              if (ok && context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  '/otp',
                                  arguments: c.phoneController.text.trim(),
                                );
                              } else if (context.mounted && c.errorText != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                        c.errorText!,
                                        style: TextStyle(
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            });
                          }
                              : null,
                          backgroundColor: c.phoneController.text.length == 11 && !c.isLoading
                              ? primary
                              : Colors.grey,
                          textColor: c.phoneController.text.length == 11 && !c.isLoading
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (c.isLoading) const LinearProgressIndicator(minHeight: 2),
                    ],
                  );
                }),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      'با ورود، شرایط و قوانین را می‌پذیرید. ',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white38, fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'بیشتر بدانید',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
