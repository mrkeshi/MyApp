import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aria/shared/styles/colors.dart';

import '../../../../shared/widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // کنترل ظاهر نوار وضعیت (Status Bar)
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // شفاف شدن پس‌زمینه‌ی نوار وضعیت
        statusBarIconBrightness: Brightness.light, // آیکن‌های استاتوس بار سفید
      ),
      child: Scaffold(
        backgroundColor: AppColors.black, // بک‌گراند کل صفحه مشکی
        body: Directionality(
          textDirection: TextDirection.rtl, // متن‌ها راست به چپ
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // تصویر بالای صفحه (عرض فیت و ارتفاع خودکار)
              Image.asset(
                'assets/images/welcome2.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),

              const SizedBox(height: 26),

              // متن خوش آمد
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'به آریا گرد خوش آمدید.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ایران رو بگرد، داستان‌هاش رو زندگی کن',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontFamily: 'customy',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: PrimaryButton(
                        text: 'ثبت نام',
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          'ثبت نام کرده‌اید؟ ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: Text(
                            'وارد شوید',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
