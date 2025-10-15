import 'package:flutter/material.dart';
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
      final c = context.read<AttractionsController>();
      c.loadTop10(widget.provinceId, force: true);
    });
  }

  Future<void> _onRefresh() async {
    await context.read<AttractionsController>().loadTop10(widget.provinceId, force: true);
  }

  @override
  Widget build(BuildContext context) {
    final divider = const Divider(height: 1, thickness: 1, color: Color(0x1AFFFFFF));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'پیشنهادی',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'براساس امتیاز کاربران، زیباترین‌ها انتخاب شده است',
                    style: TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                ),
              ),
              divider,
              Expanded(
                child: Consumer<AttractionsController>(
                  builder: (context, c, _) {
                    if (c.loading && c.top10Items.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                          itemBuilder: (_, i) => const _CardSkeleton(),
                          separatorBuilder: (_, __) => divider,
                          itemCount: 10,
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
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                        itemCount: c.top10Items.length,
                        separatorBuilder: (_, __) => divider,
                        itemBuilder: (context, index) {
                          final item = c.top10Items[index];
                          return SuggestedAttractionCard(
                            item: item,
                            baseUrl: widget.baseUrl,
                            onTap: () {
                              Navigator.of(context).pushNamed('/attraction/detail', arguments: item.id);
                            },
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.menuBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _Box(w: 50, h: 50, r: 8),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Box(w: double.infinity, h: 14, r: 4),
                SizedBox(height: 8),
                _Box(w: 160, h: 12, r: 4),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Column(
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
