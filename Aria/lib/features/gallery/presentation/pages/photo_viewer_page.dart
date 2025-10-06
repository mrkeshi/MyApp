import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:aria/features/gallery/domain/entities/photo_entity.dart';

class PhotoViewerPage extends StatefulWidget {
  final List<PhotoEntity> items;
  final int initialIndex;
  final String? title; // (اختیاری) مثلاً نام استان برای نمایش در AppBar

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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            widget.title != null
                ? '${widget.title} — ${_current + 1}/${items.length}'
                : '${_current + 1}/${items.length}',
            style: const TextStyle(fontWeight: FontWeight.w700),
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
