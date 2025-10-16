import 'package:flutter/material.dart';

class EventReviewFormPage extends StatefulWidget {
  const EventReviewFormPage({super.key});
  @override
  State<EventReviewFormPage> createState() => _EventReviewFormPageState();
}

class _EventReviewFormPageState extends State<EventReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 5;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت نظر')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              value: _rating,
              items: List.generate(5, (i) => i + 1).map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
              onChanged: (v) => setState(() => _rating = v ?? 5),
              decoration: const InputDecoration(labelText: 'امتیاز'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'نظر شما'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'متن نظر را وارد کنید' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() != true) return;
                Navigator.of(context).pop({'rating': _rating, 'comment': _controller.text.trim()});
              },
              child: const Text('ثبت'),
            )
          ],
        ),
      ),
    );
  }
}
