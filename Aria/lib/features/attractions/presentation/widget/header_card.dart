import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/url_abs.dart';
import '../../../../shared/styles/colors.dart';
import '../../../bookmark/domain/repositories/bookmark_repository.dart';

class HeaderCard extends StatefulWidget {
  final dynamic data;
  const HeaderCard({super.key, required this.data});

  @override
  State<HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  late final List<String> _images;
  late final PageController _pageCtrl;
  int _index = 0;
  bool _bookmarked = false;
  bool _loadingBm = false;

  static const double _thumbSize = 44;
  static const double _thumbGap = 8;
  static const double _thumbRadius = 6;
  static const double _thumbSelectedBorder = 1.2;

  @override
  void initState() {
    super.initState();
    final cover = (widget.data.coverImage?.isNotEmpty ?? false) ? absUrl(widget.data.coverImage) : null;
    _images = widget.data.photos.map<String>((p) => absUrl(p.image)).toList();
    if (cover != null && (_images.isEmpty || _images.first != cover)) {
      _images.insert(0, cover);
    }
    _pageCtrl = PageController(initialPage: 0);
    _initBookmark();
  }

  Future<void> _initBookmark() async {
    try {
      final repo = context.read<BookmarkRepository>();
      final ids = await repo.listIds(type: 'attraction');
      if (mounted) setState(() => _bookmarked = ids.contains(widget.data.id as int));
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 280), curve: Curves.easeInOutCubic);
  }

  Future<void> _toggleBookmark() async {
    if (_loadingBm) return;
    setState(() => _loadingBm = true);
    final old = _bookmarked;
    setState(() => _bookmarked = !old);
    try {
      final repo = context.read<BookmarkRepository>();
      final res = await repo.toggle(type: 'attraction', id: widget.data.id as int);
      if (mounted) setState(() => _bookmarked = res);
    } catch (_) {
      if (mounted) setState(() => _bookmarked = old);
    } finally {
      if (mounted) setState(() => _loadingBm = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: _images.isEmpty ? 1 : _images.length,
                    itemBuilder: (context, i) {
                      if (_images.isEmpty) {
                        return const ColoredBox(color: AppColors.grayBlack);
                      }
                      return CachedNetworkImage(imageUrl: _images[i], fit: BoxFit.cover);
                    },
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
                      child: Icon(
                        _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 16,
                        color: Colors.black,
                      ),
                      onTap: _toggleBookmark,
                    ),
                    const SizedBox(width: 6),
                    _RectIconButton(
                      background: primary,
                      padding: const EdgeInsets.all(5),
                      child: SvgPicture.asset(
                        'assets/svg/back_arrow.svg',
                        color: Colors.black,
                        width: 16,
                        height: 16,
                      ),
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_images.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: _CenteredThumbRow(
              images: _images,
              selected: _index,
              onTap: _goTo,
              thumbSize: _thumbSize,
              gap: _thumbGap,
              radius: _thumbRadius,
              selectedBorder: _thumbSelectedBorder,
              primary: primary,
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

class _CenteredThumbRow extends StatelessWidget {
  final List<String> images;
  final int selected;
  final ValueChanged<int> onTap;
  final double thumbSize, gap, radius, selectedBorder;
  final Color primary;

  const _CenteredThumbRow({
    required this.images,
    required this.selected,
    required this.onTap,
    required this.thumbSize,
    required this.gap,
    required this.radius,
    required this.selectedBorder,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final totalW = images.length * thumbSize + (images.length - 1) * gap;
        final thumbs = Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(images.length, (i) {
            final isSel = i == selected;
            return Padding(
              padding: EdgeInsetsDirectional.only(end: i == images.length - 1 ? 0 : gap),
              child: GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSel ? primary : Colors.transparent,
                      width: isSel ? selectedBorder : 0,
                    ),
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius - 1),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover),
                        if (!isSel) Container(color: Colors.black.withOpacity(0.35)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );

        if (totalW <= c.maxWidth) {
          return Center(child: thumbs);
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: thumbs,
        );
      },
    );
  }
}
