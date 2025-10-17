import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/url_abs.dart';
import '../../../../shared/styles/colors.dart';
import '../controller/events_controller.dart';

class EventHeaderCard extends StatefulWidget {
  final dynamic data;
  const EventHeaderCard({super.key, required this.data});

  @override
  State<EventHeaderCard> createState() => _EventHeaderCardState();
}

class _EventHeaderCardState extends State<EventHeaderCard> {
  bool _bookmarked = false;
  bool _loadingBm = false;

  @override
  void initState() {
    super.initState();
    _initBookmark();
  }

  Future<void> _initBookmark() async {
    final ctrl = context.read<EventsController>();
    final isSaved = await ctrl.isBookmarked(widget.data.id);
    if (mounted) setState(() => _bookmarked = isSaved);
  }

  Future<void> _toggleBookmark() async {
    if (_loadingBm) return;
    setState(() => _loadingBm = true);
    final ctrl = context.read<EventsController>();
    await ctrl.toggleBookmark(widget.data.id);
    if (mounted) {
      setState(() {
        _bookmarked = !_bookmarked;
        _loadingBm = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final imageUrl = absUrl(widget.data.coverImage);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              // تصویر کاور
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const ColoredBox(
                      color: AppColors.grayBlack,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => const ColoredBox(
                      color: AppColors.grayBlack,
                      child: Icon(Icons.broken_image, color: Colors.white38, size: 40),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 8,
                left: 8,
                child: Row(
                  children: [
                    _RectIconButton(
                      background: primary,
                      padding: const EdgeInsets.all(5),
                      onTap: _toggleBookmark,
                      child: Icon(
                        _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 6),

                    _RectIconButton(
                      background: primary,
                      padding: const EdgeInsets.all(5),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: SvgPicture.asset(
                        'assets/svg/back_arrow.svg',
                        color: Colors.black,
                        width: 16,
                        height: 16,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),


      ],
    );
  }
}

class _RectIconButton extends StatelessWidget {
  final Widget child;
  final Color background;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  const _RectIconButton({
    required this.child,
    required this.background,
    required this.onTap,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
