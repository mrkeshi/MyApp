import 'package:flutter/material.dart';

class EmptySearchPlaceholder extends StatelessWidget {
  const EmptySearchPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/images/search.png', width: 470, height: 400),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'اگر به دنبال یک مکان خاص هستید، تنها اسم یا بخشی از آدرس اون رو جستجو کنید. '
                  'نتایج مرتبط براتون نمایش داده میشه تا بتونید راحت‌تر انتخاب کنید.',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),

    );
  }
}
