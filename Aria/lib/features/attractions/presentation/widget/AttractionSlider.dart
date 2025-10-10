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
  final PageController _pageController = PageController(viewportFraction:1);
  int _currentIndex = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final controller = context.read<AttractionsController>();
      final provinceId = context.read<ProvinceController>().province?.id;
      controller.load(provinceId as int);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AttractionsController>();
    final attractions = controller.items;

    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(child: Text(controller.error!));
    }

    if (attractions.isEmpty) {
      return const Center(child: Text('هیچ جاذبه‌ای موجود نیست'));
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: attractions.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final attraction = attractions[index];
                double scale = 1.0;

                if (_pageController.position.haveDimensions) {
                  scale = (_pageController.page! - index).abs();
                  scale = 1 - (scale * 0.07).clamp(0.0, 0.07);
                }

                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
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
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
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
                            bottom: 6,
                            left: 12,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                // TODO: مسیر رفتن به جزئیات
                              },
                              child: const Text(
                                'بزن بریم',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 14),


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
                color: _currentIndex == i ? Theme.of(context).primaryColor : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
