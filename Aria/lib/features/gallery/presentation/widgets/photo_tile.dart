import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aria/features/gallery/domain/entities/photo_entity.dart';

class PhotoTile extends StatelessWidget {
  final PhotoEntity photo;
  final VoidCallback onTap;
  final double borderRadius;
  final Offset titleIconOffset;

  const PhotoTile({
    super.key,
    required this.photo,
    required this.onTap,
    this.borderRadius = 16,
    this.titleIconOffset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    final hasLoc = (photo.locationLabel?.trim().isNotEmpty ?? false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          Hero(
            tag: 'photo_${photo.id}',
            child: CachedNetworkImage(
              imageUrl: photo.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, _) => Container(color: const Color(0xFF1C1F22)),
              errorWidget: (context, _, __) => Container(
                color: const Color(0xFF303338),
                child: const Icon(Icons.broken_image, color: Colors.white54),
              ),
            ),
          ),
          Positioned.fill(child: ColoredBox(color: Colors.black12)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xB0000000), Color(0x00000000)],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.rtl,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -2),
                          child: const Icon(Icons.place_outlined, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            photo.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasLoc)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 13, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            photo.locationLabel!,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}
