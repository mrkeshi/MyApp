import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:aria/shared/styles/colors.dart';
import '../../presentation/controller/attractions_controller.dart';
import '../widget/suggested_attraction_card.dart';

class SuggestedAttractionsPage extends StatefulWidget {
  final int provinceId;
  final String? baseUrl;
  const SuggestedAttractionsPage({Key? key, required this.provinceId, this.baseUrl}) : super(key: key);

  @override
  State<SuggestedAttractionsPage> createState() => _SuggestedAttractionsPageState();
}

class _SuggestedAttractionsPageState extends State<SuggestedAttractionsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AttractionsController>().loadTop10(widget.provinceId, force: true);
    });
  }

  Future<void> _onRefresh() async {
    await context.read<AttractionsController>().loadTop10(widget.provinceId, force: true);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'پیشنهادی',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: SvgPicture.asset('assets/svg/back_arrow.svg', color: primary, width: 20, height: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'براساس امتیاز کاربران، زیباترین‌ها انتخاب شده است',
                    style: TextStyle(color: AppColors.gray, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: Consumer<AttractionsController>(
                  builder: (context, c, _) {
                    if (c.loading && c.top10Items.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                          itemCount: 10,
                          itemBuilder: (_, __) => const _CardSkeleton(),
                        ),
                      );
                    }
                    if (c.error != null && c.top10Items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('خطا در دریافت لیست پیشنهادی', style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 8),
                              Text(c.error!, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () => c.loadTop10(widget.provinceId, force: true),
                                child: const Text('تلاش دوباره'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                        itemCount: c.top10Items.length,
                        itemBuilder: (context, index) {
                          final item = c.top10Items[index];
                          final rank = index + 1;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SuggestedAttractionCard(
                              item: item,
                              rank: rank,
                              baseUrl: widget.baseUrl,
                              primaryColor: primary, // ← برای ستاره و رتبه
                              onTap: () {
                                Navigator.of(context).pushNamed('/attraction', arguments: item.id);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.menuBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          SizedBox(width: 24),
          SizedBox(width: 8),
          _Box(w: 50, h: 50, r: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Box(w: double.infinity, h: 14, r: 4),
                SizedBox(height: 8),
                _Box(w: 160, h: 12, r: 4),
              ],
            ),
          ),
          SizedBox(width: 12),
          Column(
            children: [
              _Box(w: 20, h: 20, r: 6),
              SizedBox(height: 6),
              _Box(w: 28, h: 12, r: 4),
            ],
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final double w, h, r;
  const _Box({required this.w, required this.h, required this.r, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: w == double.infinity ? MediaQuery.of(context).size.width : w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}
