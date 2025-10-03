import 'package:aria/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutDeveloperPage extends StatelessWidget {
  const AboutDeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final themed = baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(fontFamily: 'customy'),
    );

    final primary = themed.primaryColor;
    const bg = Color(0xFF111314);
    const card = AppColors.menuBackground;

    return Scaffold(
      backgroundColor: bg,
      body: Theme(
        data: themed,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 48),
                      Expanded(
                        child: Text(
                          'درباره من',
                          textAlign: TextAlign.center,
                          style: themed.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-12, 0),
                        child: IconButton(
                          padding: const EdgeInsets.all(8),
                          icon: SvgPicture.asset(
                            'assets/svg/back_arrow.svg',
                            color: primary,
                            width: 22,
                            height: 22,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primary, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 44,
                        backgroundImage:
                        AssetImage('assets/images/profile_picture.jpg'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'علیرضا کشاورز',
                      style: themed.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'توسعه دهنده',
                      // یک پله کوچیک‌تر
                      style: themed.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -2),
                        child: Container(
                          width: 2,
                          height: 22,
                          color: primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'توضیحات:',
                        style: themed.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لورم ایپسوم متن ساختگی با تولید سادگی نامفهوم از صنعت چاپ و با استفاده از طراحان گرافیک است. تکنولوژی مورد نیاز و کاربردهای متنوع؛ با هدف بهبود ابزارهای کاربردی می‌باشد.',
                    textAlign: TextAlign.justify,
                    style: themed.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سه دهه گذشته حال و آینده نشان‌دهنده توانایی جامعه و متخصصان در این طلب، تا با نرم‌افزارها شناخت بیشتری را برای طراحان ایجاد نمایند. این اعتماد در مسیر طراحی خلاق، رشد و فرهنگ بیشتر تولید محتوا را شکل داده است.',
                    textAlign: TextAlign.justify,
                    style: themed.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _ContactCard(
                    background: card,
                    leadingBg: primary,
                    icon: Icons.link_outlined,
                    label: 'www.mr-keshi.ir',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _ContactCard(
                    background: card,
                    leadingBg: primary.withOpacity(0.9),
                    icon: Icons.mail_outline,
                    label: 'mr.alireza.keshavarz@gmail.com',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final Color background;
  final Color leadingBg;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactCard({
    required this.background,
    required this.leadingBg,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.left,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: leadingBg,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
