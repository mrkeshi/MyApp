import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/styles/colors.dart';
import '../../../province/presentation/controller/province_controller.dart';
import '../controller/attractions_controller.dart';

class AttractionSlider extends StatefulWidget {
  final double height;
  final double viewportFraction;
  final double outerClipRadius;
  final double cardRadius;
  final EdgeInsetsGeometry pageHorizontalMargin;
  final String ctaText;
  final Color? indicatorActiveColor;
  final Color? indicatorInactiveColor;
  final void Function(int id)? onTapCta;

  const AttractionSlider({
    Key? key,
    this.height = 180,
    this.viewportFraction = 1,
    this.outerClipRadius = 8,
    this.cardRadius = 20,
    this.pageHorizontalMargin = const EdgeInsets.symmetric(horizontal: 6),
    this.ctaText = 'بزن بریم',
    this.indicatorActiveColor,
    this.indicatorInactiveColor,
    this.onTapCta,
  }) : super(key: key);

  @override
  State<AttractionSlider> createState() => _AttractionSliderState();
}

class _AttractionSliderState extends State<AttractionSlider> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);
  }

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
      return SizedBox(
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.error != null) {
      return SizedBox(
        height: widget.height,
        child: Center(child: Text(controller.error!)),
      );
    }

    if (attractions.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('هیچ جاذبه‌ای موجود نیست')),
      );
    }

    final activeColor = widget.indicatorActiveColor ?? Theme.of(context).primaryColor;
    final inactiveColor = widget.indicatorInactiveColor ?? Colors.grey.shade400;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.outerClipRadius),
          child: SizedBox(
            height: widget.height,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: attractions.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final attraction = attractions[index];
                return Container(
                  margin: widget.pageHorizontalMargin,
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
                    borderRadius: BorderRadius.circular(widget.cardRadius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          attraction.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              if (widget.onTapCta != null) {
                                widget.onTapCta!(attraction.id);
                              }
                            },
                            child: Text(
                              widget.ctaText,
                              style: const TextStyle(
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
                color: _currentIndex == i ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
