import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutDeveloperPage extends StatelessWidget {
  const AboutDeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svg/back_arrow.svg', // مسیر آیکن برگشت
            color: primary,
            width: 20,
            height: 20,
          ),
          onPressed: () => Navigator.pop(context), // برگشت به صفحه قبلی
        ),
        title: Text('درباره توسعه‌دهنده', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: const Color(0xFF111314),
      ),
      backgroundColor: const Color(0xFF111314),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/profile_picture.png'), // مسیر تصویر پروفایل
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'علیرضا کشاورز',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Center(
              child: Text(
                'توسعه‌دهنده',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // توضیحات
            Text(
              'لورم ایپسوم متن ساختگی با تولید سادگی نامفهوم از صنعت چاپ و با استفاده از طراحان گرافیک است. '
                  'کنترل‌های مورد نیاز و کاربردهای متفاوت با همین بهبود ارتباط کاربری می‌باشد. این دقت در دنیای طراحی '
                  'و جنبه‌های گوناگون طراحی سایت و توسعه‌دهندگان، بسیاری از طراحان و نویسندگان محبوب را درگیر کرده است.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            // لینک‌ها
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.language, color: primary),
                  onPressed: () {
                  },
                ),
                Text(
                  'www.mr-keshi.ir',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.mail, color: primary),
                  onPressed: () {

                  },
                ),
                Text(
                  'mr.alireza.keshavarz@gmail.com',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
