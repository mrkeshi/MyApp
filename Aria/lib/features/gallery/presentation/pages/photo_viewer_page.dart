import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:aria/features/gallery/domain/entities/photo_entity.dart';

import '../../../../core/utils/formatters.dart';

class PhotoViewerPage extends StatefulWidget {
  final List<PhotoEntity> items;
  final int initialIndex;
  final String? title;

  const PhotoViewerPage({
    super.key,
    required this.items,
    required this.initialIndex,
    this.title,
  });

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late PageController _pageController;
  late int _current;

  final _formatter = PersianDigitsFormatter();

  String _formatFa(String text) {
    final oldValue = const TextEditingValue(text: '');
    final newValue = TextEditingValue(text: text);
    final result = _formatter.formatEditUpdate(oldValue, newValue);
    return result.text;
  }

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _current = index);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final primary = Theme.of(context).primaryColor;

    final faCount = _formatFa('${_current + 1}/${items.length}');
    final titleText = widget.title ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/svg/back_arrow.svg',
            color: primary,
            width: 20,
            height: 20,
          ),
        ),
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'customy',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              children: [
                if (titleText.isNotEmpty) ...[
                  TextSpan(text: titleText),
                  TextSpan(
                    text: ' - ',
                    style: TextStyle(color: primary),
                  ),
                ],
                TextSpan(text: faCount),
              ],
            ),
          ),
        ),
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: items.length,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        loadingBuilder: (_, __) => const Center(child: CircularProgressIndicator()),
        builder: (context, index) {
          final p = items[index];
          return PhotoViewGalleryPageOptions(
            heroAttributes: PhotoViewHeroAttributes(tag: 'photo_${p.id}'),
            imageProvider: NetworkImage(p.imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3.0,
          );
        },
      ),
    );
  }
}
