import 'package:aria/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:aria/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:aria/features/gallery/presentation/widgets/photo_tile.dart';
import 'package:aria/features/gallery/presentation/pages/photo_viewer_page.dart';
import 'package:aria/features/province/presentation/controller/province_controller.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final province = context.watch<ProvinceController>().province;
    final galleryController = context.read<GalleryController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (province != null) {
        galleryController.load(province.id);
      }
    });

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

    return _GalleryBody(provinceNameFa: province.nameFa);
  }
}

class _GalleryBody extends StatelessWidget {
  final String provinceNameFa;
  const _GalleryBody({required this.provinceNameFa});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<GalleryController>();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'گالری $provinceNameFa',
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'customy',
                fontSize: 17),
          ),
        ),
      ),
      body: Builder(builder: (_) {
        if (controller.loading && controller.items.isEmpty) {
          return const _SkeletonGrid();
        }

        if (controller.error != null && controller.items.isEmpty) {
          return Center(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                controller.error!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
            ),
          );
        }

        if (controller.items.isEmpty) {
          return const Center(
            child: Text(
              'عکسی یافت نشد',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final photo = controller.items[index];
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
                            items: controller.items,
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
      }),
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
