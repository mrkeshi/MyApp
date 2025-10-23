import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aria/shared/styles/colors.dart';
import '../controllers/bookmark_controller.dart';

class BookmarksPage extends StatefulWidget {
  final String? baseUrl;
  const BookmarksPage({super.key, this.baseUrl});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BookmarkController>().loadAll();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<BookmarkController>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          title: const Text(
            'بوکمارک‌ها',
            style: TextStyle(
              fontFamily: 'customy',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.black,
          elevation: 0,
        ),
        body: Consumer<BookmarkController>(
          builder: (context, c, _) {
            if (c.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (c.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'خطا در دریافت بوکمارک‌ها\n${c.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _onRefresh,
                      child: const Text('تلاش مجدد'),
                    ),
                  ],
                ),
              );
            }
            if (c.items.isEmpty) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                color: Colors.white,
                backgroundColor: const Color(0xFF1E1E1E),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 100),
                    Center(
                      child: Text('هنوز چیزی بوکمارک نکردی', style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.white,
              backgroundColor: const Color(0xFF1E1E1E),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                itemCount: c.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final it = c.items[i];
                  final bookmarked = c.isBookmarked(it.type, it.id);
                  return _BookmarkRow(
                    title: it.title,
                    subtitle: it.address ?? 'بدون توضیحات',
                    thumbUrl: it.coverImage ?? '',
                    baseUrl: widget.baseUrl,
                    bookmarked: bookmarked,
                    onToggle: () => c.toggle(it.type, it.id, removeFromList: false),
                    onTap: () {
                      if (it.type == 'attraction') {
                        Navigator.pushNamed(context, '/attraction', arguments: it.id);
                      } else {
                        Navigator.pushNamed(context, '/event', arguments: it.id);
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BookmarkRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String thumbUrl;
  final String? baseUrl;
  final bool bookmarked;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const _BookmarkRow({
    required this.title,
    required this.subtitle,
    required this.thumbUrl,
    required this.bookmarked,
    required this.onToggle,
    this.baseUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 10.0;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.menuBackground,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _ThumbImage(url: thumbUrl, size: 48, baseUrl: baseUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 15.5, height: 1)),
                      const SizedBox(height: 6),
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.gray, fontSize: 12.5, height: 1.1)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onToggle,
                  tooltip: 'بوکمارک',
                  icon: Icon(
                    bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: bookmarked ? Theme.of(context).primaryColor : Colors.white70,
                  ),
                ),
              ],
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
    final base = widget.baseUrl?.trim().replaceAll(RegExp(r'/$'), '') ?? 'https://aria.penvis.ir';
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
          ? Image.network(resolved, key: const ValueKey('thumb-ready'), width: widget.size, height: widget.size, fit: BoxFit.cover)
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
