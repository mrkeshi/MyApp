import 'package:flutter/material.dart';
import '../../../attractions/presentation/widget/AttractionSlider.dart';
import '../../../attractions/presentation/widget/local_events_grid.dart.dart';
import '../widgets/header_widget.dart';
import '../widgets/attraction_box_grid.dart';

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
              const HeaderWidget(),
              const SizedBox(height: 0),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AttractionSlider(),
              ),

              const SizedBox(height: 12),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: AttractionBoxGrid(),
              ),

              const SizedBox(height: 0),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: LocalEventsGrid(),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/about-province');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'رفتن به صفحه استان',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
