import 'package:flutter/material.dart';
import '../../../attractions/presentation/widget/AttractionSlider.dart';
import '../widgets/local_events_grid.dart.dart';
import '../widgets/header_widget.dart';
import '../widgets/attraction_box_grid.dart';
import '../widgets/service_grid.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Transform.translate(
                offset: const Offset(0, 0),
                child: const HeaderWidget(),
              ),
              const SizedBox(height: 0),
              Transform.translate(
                offset: const Offset(0, 0),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: AttractionSlider(),
                ),
              ),
              const SizedBox(height: 4),
              Transform.translate(
                offset: const Offset(0, -6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: AttractionBoxGrid(),
                ),
              ),
              const SizedBox(height: 0),
              Transform.translate(
                offset: const Offset(0, -8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: LocalEventsGrid(),
                ),
              ),
              const SizedBox(height: 0),

              Transform.translate(
                offset: const Offset(0, -2),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SoonServicesGrid(),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
