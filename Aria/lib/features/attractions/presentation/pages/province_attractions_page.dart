import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../shared/styles/colors.dart';
import '../../../province/presentation/controller/province_controller.dart';
import '../controller/attractions_controller.dart';
import 'attraction_card.dart';
import 'empty_search_placeholder.dart';

enum _SearchMode { idleSlider, typingEmpty, submittedResults }

class ProvinceAttractionsPage extends StatefulWidget {
  const ProvinceAttractionsPage({Key? key}) : super(key: key);

  @override
  State<ProvinceAttractionsPage> createState() => _ProvinceAttractionsPageState();
}

class _ProvinceAttractionsPageState extends State<ProvinceAttractionsPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late AttractionsController _controller;
  bool _initialized = false;
  _SearchMode _mode = _SearchMode.idleSlider;
  String _searchQuery = '';
  int _currentPage = 0;
  late PageController _pageController;
  bool _initialJumpDone = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _searchController.addListener(() {
      final q = _searchController.text;
      if (q.isEmpty && _mode != _SearchMode.idleSlider) {
        setState(() {
          _searchQuery = '';
          _mode = _SearchMode.idleSlider;
        });
      } else if (q.isNotEmpty && _mode != _SearchMode.typingEmpty) {
        setState(() {
          _searchQuery = q;
          _mode = _SearchMode.typingEmpty;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _controller = context.read<AttractionsController>();
      final province = context.read<ProvinceController>().province;
      if (province != null) {
        _controller.loadAllAttractions(province.id);
      }
      _initialized = true;
    }
  }

  Future<void> _onSubmit(String query) async {
    final q = query.trim();
    FocusScope.of(context).unfocus();
    if (q.isEmpty) {
      setState(() {
        _searchQuery = '';
        _mode = _SearchMode.idleSlider;
      });
      return;
    }
    setState(() {
      _searchQuery = q;
      _mode = _SearchMode.submittedResults;
    });
    await _controller.search(q);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {
      _searchQuery = '';
      _mode = _SearchMode.idleSlider;
    });
  }

  @override
  Widget build(BuildContext context) {
    final province = context.watch<ProvinceController>().province;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF0E0E0E),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: SvgPicture.asset(
                        'assets/svg/back_arrow.svg',
                        color: primary,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'جاذبه های گردشگری ${province?.nameFa ?? ''}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _onSubmit,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'جستجو کنید ...',
                      hintStyle: const TextStyle(
                        color: AppColors.iconColor,
                        fontSize: 14,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.search,
                          color: AppColors.iconColor,
                          size: 23,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      suffixIcon: (_searchQuery.isNotEmpty || _mode != _SearchMode.idleSlider)
                          ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.iconColor,
                          size: 24,
                        ),
                      )
                          : null,
                      filled: true,
                      fillColor: AppColors.menuBackground,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: AppColors.iconColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: primary,
                          width: 1.2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 10,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              Expanded(
                child: Consumer<AttractionsController>(
                  builder: (_, controller, __) {
                    if (_mode == _SearchMode.submittedResults) {
                      if (controller.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final results = controller.searchItems;
                      if (results.isEmpty) {
                        return Center(
                          child: NoResultsPlaceholder(
                            query: _searchQuery,
                            primary: primary,
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: results.length,
                        itemBuilder: (_, i) => SearchAttractionCard(
                          result: results[i],
                          onTap: () => Navigator.pushNamed(context, '/attraction', arguments: results[i].id),
                        ),
                      );
                    }

                    if (_mode == _SearchMode.typingEmpty) {
                      return const EmptySearchPlaceholder();
                    }

                    if (controller.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = controller.allItems;
                    if (items.isEmpty) {
                      return Center(
                        child: NoResultsPlaceholder(
                          query: '',
                          primary: primary,
                        ),
                      );
                    }

                    if (!_initialJumpDone && items.isNotEmpty) {
                      final mid = (items.length / 2).floor();
                      _currentPage = mid;
                      _initialJumpDone = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _pageController.jumpToPage(mid);
                        setState(() {});
                      });
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = constraints.maxWidth;
                        const thumbnailsHeight = 64.0;
                        const slideTopPadding = 24.0;
                        const spacingAboveThumbs = 8.0;
                        const spacingBelowThumbs = 28.0;
                        const itemHorizontalPadding = 14.0;
                        final maxPageAreaHeight = constraints.maxHeight - thumbnailsHeight - spacingAboveThumbs - spacingBelowThumbs - slideTopPadding;
                        final pageWidth = screenWidth * _pageController.viewportFraction;
                        double imageSize = math.min(pageWidth - (itemHorizontalPadding * 2), maxPageAreaHeight - 40.0);
                        imageSize = imageSize.clamp(170.0, 640.0);
                        const thumbSize = 58.0;

                        return Column(
                          children: [
                            const SizedBox(height: slideTopPadding),
                            Expanded(
                              child: Center(
                                child: SizedBox(
                                  height: maxPageAreaHeight,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: (index) => setState(() => _currentPage = index),
                                    itemCount: items.length,
                                    padEnds: true,
                                    clipBehavior: Clip.none,
                                    itemBuilder: (context, index) {
                                      final attraction = items[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: itemHorizontalPadding, vertical: 14),
                                        child: AnimatedBuilder(
                                          animation: _pageController,
                                          builder: (context, child) {
                                            double value = 1.0;
                                            if (_pageController.position.haveDimensions) {
                                              value = (_pageController.page! - index).abs();
                                              value = (1 - (value * 0.2)).clamp(0.9, 1.0);
                                            }
                                            return Transform.scale(
                                              scale: Curves.easeOut.transform(value),
                                              child: child,
                                            );
                                          },
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(20),
                                            onTap: () => Navigator.pushNamed(context, '/attraction', arguments: attraction.id),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(20),
                                                  child: SizedBox(
                                                    width: imageSize,
                                                    height: imageSize,
                                                    child: Image.network(
                                                      attraction.coverImage,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (loadingProgress == null) return child;
                                                        return ShimmerBox(width: imageSize, height: imageSize, radius: 20);
                                                      },
                                                      errorBuilder: (_, __, ___) => Container(
                                                        color: Colors.black26,
                                                        child: const Center(
                                                          child: Icon(Icons.image_not_supported, color: Colors.white70),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 34),
                                                Text(
                                                  attraction.title,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  attraction.venue,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 13,
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
                            ),
                            const SizedBox(height: spacingAboveThumbs),
                            SizedBox(
                              height: thumbnailsHeight,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(items.length, (index) {
                                    final attraction = items[index];
                                    final isSelected = index == _currentPage;
                                    return GestureDetector(
                                      onTap: () => _pageController.animateToPage(
                                        index,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: AnimatedOpacity(
                                            duration: const Duration(milliseconds: 200),
                                            opacity: isSelected ? 1.0 : 0.45,
                                            child: Image.network(
                                              attraction.coverImage,
                                              width: thumbSize,
                                              height: thumbSize,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return ShimmerBox(width: thumbSize, height: thumbSize, radius: 12);
                                              },
                                              errorBuilder: (_, __, ___) => Container(
                                                width: thumbSize,
                                                height: thumbSize,
                                                color: Colors.black26,
                                                child: const Icon(Icons.image_not_supported, color: Colors.white70, size: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(height: spacingBelowThumbs),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoResultsPlaceholder extends StatelessWidget {
  final String query;
  final Color primary;

  const NoResultsPlaceholder({Key? key, required this.query, required this.primary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.travel_explore, color: Colors.white38, size: 56),
            const SizedBox(height: 12),
            hasQuery
                ? RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6, fontFamily: 'customy'),
                children: [
                  const TextSpan(text: 'برای '),
                  TextSpan(text: '«$query»', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' یافت نشد.'),
                ],
              ),
            )
                : const Text(
              'جاذبه‌ای یافت نشد.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({Key? key, required this.width, required this.height, this.radius = 12}) : super(key: key);
  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}
class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }
  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: Stack(
            children: [
              Container(
                width: widget.width,
                height: widget.height,
                color: const Color(0xFF1E1E1E),
              ),
              Transform.translate(
                offset: Offset((widget.width + widget.height) * (_ac.value * 2 - 1), 0),
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1, -0.2),
                      end: Alignment(1, 0.2),
                      colors: [Color(0x001E1E1E), Color(0x33FFFFFF), Color(0x001E1E1E)],
                      stops: [0.35, 0.5, 0.65],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
