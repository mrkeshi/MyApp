import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/events_controller.dart';
import '../widgets/event_card.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});
  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<EventsController>().fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('رویدادها')),
      body: vm.loadingList
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: vm.fetchAll,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (_, i) => EventCard(item: vm.items[i]),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemCount: vm.items.length,
        ),
      ),
    );
  }
}
