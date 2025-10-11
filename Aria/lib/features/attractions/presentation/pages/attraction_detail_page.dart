import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/attraction_detail.dart';
import '../controller/attractions_controller.dart';

class AttractionDetailPage extends StatefulWidget {
  final int id;
  const AttractionDetailPage({super.key, required this.id});

  @override
  State<AttractionDetailPage> createState() => _AttractionDetailPageState();
}

class _AttractionDetailPageState extends State<AttractionDetailPage> {
  late Future<AttractionDetail?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AttractionsController>().getDetail(widget.id);
  }

  String _abs(String url) {
    if (url.startsWith('http')) return url;
    return 'http://10.0.2.2:8000$url';
  }

  Widget _stars(double v) {
    final full = v.floor();
    final half = (v - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) return const Icon(Icons.star, size: 18, color: Colors.amber);
        if (i == full && half) return const Icon(Icons.star_half, size: 18, color: Colors.amber);
        return const Icon(Icons.star_border, size: 18, color: Colors.amber);
      }),
    );
  }

  Future<void> _openInMaps(AttractionDetail data) async {
    final lat = data.latitude;
    final lon = data.longitude;
    if (lat.isEmpty || lon.isEmpty) return;
    final Uri googleMapUri = Uri.parse('geo:$lat,$lon?q=$lat,$lon(${data.title})');
    if (await canLaunchUrl(googleMapUri)) {
      await launchUrl(googleMapUri);
    } else {
      final Uri webMapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
      if (await canLaunchUrl(webMapUri)) {
        await launchUrl(webMapUri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF111314),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111314),
          foregroundColor: Colors.white,
          title: const Text('جزئیات جاذبه'),
          centerTitle: true,
          elevation: 0,
        ),
        body: FutureBuilder<AttractionDetail?>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return const Center(child: Text('خطا در دریافت اطلاعات', style: TextStyle(color: Colors.white70)));
            }
            final data = snap.data;
            if (data == null) {
              return const Center(child: Text('داده‌ای یافت نشد', style: TextStyle(color: Colors.white70)));
            }
            final cover = data.coverImage.isNotEmpty ? _abs(data.coverImage) : null;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (cover != null)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                            child: Image.network(cover, fit: BoxFit.cover),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                data.title,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _stars(data.averageRating),
                                const SizedBox(height: 4),
                                Text(
                                  '${data.averageRating.toStringAsFixed(1)} (${data.reviewsCount})',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (data.shortDescription.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(data.shortDescription, style: const TextStyle(color: Colors.white70)),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            const Icon(Icons.place, color: Colors.white70, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(data.venue, style: const TextStyle(color: Colors.white70)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _openInMaps(data),
                              icon: const Icon(Icons.map),
                              label: const Text('نمایش روی نقشه'),
                            ),
                          ],
                        ),
                      ),
                      if (data.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Text(data.description, style: const TextStyle(color: Colors.white, height: 1.6)),
                        ),
                      const SizedBox(height: 16),
                      if (data.photos.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('عکس‌ها', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 160,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                scrollDirection: Axis.horizontal,
                                itemCount: data.photos.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  final p = data.photos[i];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(_abs(p.image), width: 220, height: 160, fit: BoxFit.cover),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      if (data.reviews.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('نظرات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            ...data.reviews.take(10).map((r) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1D1F),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(radius: 14, child: Text(r.userDisplay.isNotEmpty ? r.userDisplay.characters.first : '؟')),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(r.userDisplay, style: const TextStyle(color: Colors.white))),
                                          Row(
                                            children: List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 16, color: Colors.amber)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(r.comment, style: const TextStyle(color: Colors.white70)),
                                      const SizedBox(height: 4),
                                      Text(r.createdAt, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
