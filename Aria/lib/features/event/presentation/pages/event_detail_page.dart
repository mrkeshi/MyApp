import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/styles/colors.dart';
import '../../domain/entities/event_detail.dart';
import '../controller/events_controller.dart';
import '../widgets/event_header_card.dart' as hdr;
import '../widgets/event_info_card.dart';
import '../widgets/event_tabs_row.dart';
import '../widgets/event_details_section.dart' as det;
import '../widgets/event_map_section.dart' as mapsec;
import '../widgets/event_reviews_section.dart' as rev;

class EventDetailStyledPage extends StatefulWidget {
  final int id;
  const EventDetailStyledPage({super.key, required this.id});

  @override
  State<EventDetailStyledPage> createState() => _EventDetailStyledPageState();
}

class _EventDetailStyledPageState extends State<EventDetailStyledPage> {
  late Future<EventDetail?> _future;
  int _tabIndex = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _future = context.read<EventsController>().fetchDetail(widget.id);
      setState(() {});
    });
  }

  Future<void> _refresh() async {
    final f = context.read<EventsController>().fetchDetail(widget.id, force: true);
    setState(() => _future = f);
    await f;
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
          child: FutureBuilder<EventDetail?>(
            future: _future,
            builder: (context, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  children: const [
                    SizedBox(height: 240),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }

              if (s.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  children: [
                    const SizedBox(height: 200),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white54, size: 40),
                          const SizedBox(height: 12),
                          const Text('خطا در دریافت اطلاعات', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _refresh,
                            child: const Text('تلاش مجدد', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              final data = s.data;
              if (data == null) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  children: const [
                    SizedBox(height: 200),
                    Center(child: Text('چیزی پیدا نشد', style: TextStyle(color: Colors.white70))),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  hdr.EventHeaderCard(data: data),
                  const SizedBox(height: 8),
                  EventInfoCard(data: data),
                  const SizedBox(height: 12),
                  EventTabsRow(index: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i)),
                  const SizedBox(height: 12),
                  if (_tabIndex == 0) det.EventDetailsSection(data: data),
                  if (_tabIndex == 1) mapsec.EventMapSection(data: data),
                  if (_tabIndex == 2) rev.EventReviewsSection(data: data),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
