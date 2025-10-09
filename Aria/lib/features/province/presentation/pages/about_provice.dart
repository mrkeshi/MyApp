import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../shared/styles/colors.dart';
import '../controller/province_controller.dart';

class ProvincePage extends StatelessWidget {
  const ProvincePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProvinceController>(
      builder: (context, controller, _) {
        final province = controller.province;

        final baseTheme = Theme.of(context);
        final themed = baseTheme.copyWith(
          textTheme: baseTheme.textTheme.apply(fontFamily: 'customy'),
        );
        final primary = themed.primaryColor;
        const bg = AppColors.black;
        const card = AppColors.menuBackground;

        if (province == null) {
          return const Scaffold(
            backgroundColor: bg,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: bg,
          body: Theme(
            data: themed,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          const SizedBox(width: 48),
                          Expanded(
                            child: Text(
                              province.nameFa,
                              textAlign: TextAlign.center,
                              style: themed.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 18
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

                      const SizedBox(height: 10),


                      SizedBox(
                        height: 320,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor],
                            ).createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: Image.network(
                              province.mapImage,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade800,
                                  child: const Center(
                                    child: CircularProgressIndicator(color: Colors.white70),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade800,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
                                  ),
                                );
                              },
                            ),
                          )


                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'جمعیت',
                                style: themed.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                province.population,
                                style: themed.textTheme.bodyLarge?.copyWith(
                                  color: primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'مساحت',
                                style: themed.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                province.area,
                                style: themed.textTheme.bodyLarge?.copyWith(
                                    color: primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          province.description,
                          style: themed.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
