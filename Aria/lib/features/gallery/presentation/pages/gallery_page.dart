import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import 'package:aria/features/gallery/domain/repositories/photo_repository.dart';
import 'package:aria/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:aria/features/gallery/presentation/widgets/photo_tile.dart';
import 'package:aria/features/gallery/presentation/pages/photo_viewer_page.dart';

import 'package:aria/features/province/presentation/controller/province_controller.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // استان انتخاب‌شده از کنترلر استان
    final provinceCtrl = context.watch<ProvinceController>();
    final province = provinceCtrl.province;

    if (province == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF111314),
        body: Center(
          child: Text(
            'استانی انتخاب نشده است',
            style: TextStyle(color: Colors.white70),
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }

    final repo = context.read<PhotoRepository>();

    return ChangeNotifierProvider<GalleryController>(
      // لود بر اساس province.id
      create: (_) => GalleryController(repo)..load(province.id),
      child: _GalleryBody(provinceNameFa: province.nameFa),
    );
  }
}

class _GalleryBody extends StatelessWidget {
  final String provinceNameFa;
  const _GalleryBody({required this.provinceNameFa});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF111314),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111314),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'گالری $provinceNameFa',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Consumer<GalleryController>(
        builder: (context, c, _) {
          if (c.loading) return const _SkeletonGrid();

          if (c.error != null) {
            return Center(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  c.error!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ),
            );
          }

          if (c.items.isEmpty) {
            return const Center(
              child: Text(
                'عکسی یافت نشد',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => c.refresh(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: c.items.length,
                itemBuilder: (context, index) {
                  final photo = c.items[index];
                  final height = (index % 4 == 0 || index % 4 == 3) ? 220.0 : 160.0;

                  return SizedBox(
                    height: height,
                    child: PhotoTile(
                      photo: photo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotoViewerPage(
                              items: c.items,
                              initialIndex: index,
                              title: provinceNameFa,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: 8,
        itemBuilder: (context, index) {
          final h = (index % 4 == 0 || index % 4 == 3) ? 220.0 : 160.0;
          return Container(
            height: h,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1C1E),
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }
}
