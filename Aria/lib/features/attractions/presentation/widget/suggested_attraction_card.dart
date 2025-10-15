import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:aria/shared/styles/colors.dart';
import '../../../../core/utils/formatters.dart' show toFaDigits;
import '../../domain/entities/attraction.dart';

import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:aria/shared/styles/colors.dart';
import '../../../../core/utils/formatters.dart' show faDigits; // ← تابع شما
import '../../domain/entities/attraction.dart';

class SuggestedAttractionCard extends StatelessWidget {
  final Attraction item;
  final VoidCallback? onTap;
  final double radius;
  final double thumbSize;
  final Color? cardColor;
  final String? baseUrl;

  const SuggestedAttractionCard({
    Key? key,
    required this.item,
    this.onTap,
    this.radius = 8.0,
    this.thumbSize = 50.0,
    this.cardColor,
    this.baseUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = cardColor ?? AppColors.menuBackground;
    final ratingFa = faDigits(item.averageRating.toStringAsFixed(2)); // ← اینجا استفاده شد

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _ThumbImage(
                      url: item.coverImage,
                      size: thumbSize,
                      baseUrl: baseUrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            wordSpacing: -3,
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.shortDescription.isNotEmpty
                              ? item.shortDescription
                              : 'بدون توضیحات',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: AppColors.gray,
                            fontSize: 12.5,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        ratingFa,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
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

class _ThumbImage extends StatefulWidget {
  final String url;
  final double size;
  final String? baseUrl;
  const _ThumbImage({Key? key, required this.url, required this.size, this.baseUrl}) : super(key: key);

  @override
  State<_ThumbImage> createState() => _ThumbImageState();
}

class _ThumbImageState extends State<_ThumbImage> {
  bool _loaded = false;
  bool _error = false;

  String _abs(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = widget.baseUrl?.trim().replaceAll(RegExp(r'/$'), '') ?? 'http://10.0.2.2:8000';
    final path = url.trim().startsWith('/') ? url.trim() : '/${url.trim()}';
    return '$base$path';
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _abs(widget.url);

    if (resolved.isEmpty || _error) {
      return Container(
        width: widget.size,
        height: widget.size,
        color: const Color(0xFF2A2A2A),
        child: const Icon(Icons.image_not_supported, color: AppColors.gray, size: 20),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _loaded
          ? Image.network(
        resolved,
        key: const ValueKey('thumb-ready'),
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
      )
          : Stack(
        key: const ValueKey('thumb-loading'),
        alignment: Alignment.center,
        children: [
          _ShimmerBox(width: widget.size, height: widget.size, radius: 8),
          Image.network(
            resolved,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _loaded = true);
                });
                return child;
              }
              return const SizedBox.shrink();
            },
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _error = true);
              });
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBox({Key? key, required this.width, required this.height, this.radius = 12}) : super(key: key);

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
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
              Container(width: widget.width, height: widget.height, color: const Color(0xFF232323)),
              Transform.translate(
                offset: Offset((widget.width + widget.height) * (_ac.value * 2 - 1), 0),
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1, -0.2),
                      end: Alignment(1, 0.2),
                      colors: [Color(0x00232323), Color(0x44FFFFFF), Color(0x00232323)],
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
