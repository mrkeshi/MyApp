import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/styles/colors.dart';
import '../../domain/entities/attraction_detail.dart';
import '../controller/attractions_controller.dart';
import '../widget/details_section.dart';
import '../widget/header_card.dart';
import '../widget/info_card.dart';
import '../widget/map_section.dart';
import '../widget/reviews_section.dart';
import '../widget/tabs_row.dart';


class AttractionDetailStyledPage extends StatefulWidget {
  final int id;
  const AttractionDetailStyledPage({super.key, required this.id});

  @override
  State<AttractionDetailStyledPage> createState() => _AttractionDetailStyledPageState();
}

class _AttractionDetailStyledPageState extends State<AttractionDetailStyledPage> {
  late Future<AttractionDetail?> _future;
  int _tabIndex = 1;

  @override
  void initState() {
    super.initState();
    _future = context.read<AttractionsController>().getDetail(widget.id);
  }

  Future<void> _refresh() async {
    _future = context.read<AttractionsController>().getDetail(widget.id);
    setState(() {});
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          backgroundColor: AppColors.black,
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<AttractionDetail?>(
            future: _future,
            builder: (context, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (s.hasError) {
                return Center(child: TextButton(onPressed: _refresh, child: const Text('خطا، تلاش مجدد')));
              }
              final data = s.data;
              if (data == null) {
                return const Center(child: Text('چیزی پیدا نشد', style: TextStyle(color: Colors.white70)));
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                children: [
                  HeaderCard(data: data),
                  const SizedBox(height: 8),
                  InfoCard(data: data),
                  const SizedBox(height: 12),
                  TabsRow(index: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i)),
                  const SizedBox(height: 12),
                  if (_tabIndex == 0) DetailsSection(data: data),
                  if (_tabIndex == 1) MapSection(data: data),
                  if (_tabIndex == 2) ReviewsSection(data: data),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
