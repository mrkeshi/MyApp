import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/styles/colors.dart';
import '../../../province/presentation/controller/province_controller.dart';
import '../controller/attractions_controller.dart';

class AttractionSlider extends StatefulWidget {
  const AttractionSlider({Key? key}) : super(key: key);

  @override
  State<AttractionSlider> createState() => _AttractionSliderState();
}

class _AttractionSliderState extends State<AttractionSlider> {
  final PageController _pageController = PageController(viewportFraction: 1);
  int _currentIndex = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final controller = context.read<AttractionsController>();
      final provinceId = context.read<ProvinceController>().province?.id;
      if (provinceId != null) {
        controller.loadTop3(provinceId);
        _initialized = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AttractionsController>();
    final attractions = controller.top3Items;

    if (controller.loading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.error != null) {
      return SizedBox(
        height: 180,
        child: Center(child: Text(controller.error!)),
      );
    }

    if (attractions.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('هیچ جاذبه‌ای موجود نیست')),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 180, 
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: attractions.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final attraction = attractions[index];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          attraction.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.broken_image)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 12,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              // TODO: رفتن به صفحه جزئیات
                            },
                            child: const Text(
                              'بزن بریم',
                              style: TextStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            attractions.length,
                (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentIndex == i ? 16 : 10,
              height: 3,
              decoration: BoxDecoration(
                color: _currentIndex == i
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
