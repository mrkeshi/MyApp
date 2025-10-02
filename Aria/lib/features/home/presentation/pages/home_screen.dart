import 'package:flutter/material.dart';

/// ----------------------
/// تنظیمات ظاهری (قابل تغییر)
/// ----------------------
const _scaffoldBg = Color(0xFF1E2226);   // پس‌زمینه کلی
const _barBg = Color(0xFF262B30);        // پس‌زمینه نوار
const _iconIdle = Color(0xFF8A8F94);     // رنگ آیکن‌های غیرفعال
const _yellow = Color(0xFFFFC400);       // زرد دکمه
const _barHeight = 72.0;                 // ارتفاع نوار
const _barRadius = 24.0;                 // گردی گوشه‌های نوار
const _notchRadius = 36.0;               // شعاع گودی زیر دکمه
const _fabSize = 64.0;                   // قطر دکمه گرد زرد
const _rightInset = 18.0;                // فاصله دکمه از راست
const _topLift = 18.0;                   // بیرون‌زدگی دکمه از لبه‌ی بالا

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _scaffoldBg,
        title: const Text("صفحه اصلی"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'به اپ خوش آمدید!',
          style: TextStyle(fontSize: 24, color: Colors.white.withOpacity(.95)),
        ),
      ),

      // Bottom Bar سفارشی + دکمه زرد
      bottomNavigationBar: SizedBox(
        height: _barHeight + 28, // کمی فضا برای سایه و دکمه
        child: Stack(
          children: [
            // خودِ نوار پِینت می‌شود
            Positioned.fill(
              child: CustomPaint(
                painter: _CurvedBarPainter(),
                child: SizedBox(
                  height: _barHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BarIcon(
                          icon: Icons.person_outline,
                          active: _index == 0,
                          onTap: () => setState(() => _index = 0),
                        ),
                        _BarIcon(
                          icon: Icons.bookmark_border,
                          active: _index == 1,
                          onTap: () => setState(() => _index = 1),
                        ),
                        _BarIcon(
                          icon: Icons.image_outlined,
                          active: _index == 2,
                          onTap: () => setState(() => _index = 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // دکمه زرد گوشه‌ی راست با سایه
            Positioned(
              right: _rightInset,
              // کمی بالاتر از لبه‌ی بالایی نوار قرار می‌گیرد
              bottom: _barHeight - _fabSize / 2 + _topLift,
              child: PhysicalModel(
                color: Colors.transparent,
                elevation: 8,
                shadowColor: Colors.black.withOpacity(.5),
                shape: BoxShape.circle,
                child: Container(
                  width: _fabSize,
                  height: _fabSize,
                  decoration: const BoxDecoration(
                    color: _yellow,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() => _index = 99); // Home فعال
                      // TODO: اینجا ناوبری انجام بده
                      // Navigator.pushNamed(context, '/home');
                    },
                    icon: const Icon(Icons.home_outlined, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// آیکن ساده‌ی نوار
class _BarIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _BarIcon({
    Key? key,
    required this.icon,
    required this.active,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          icon,
          size: 26,
          color: _iconIdle.withOpacity(active ? .95 : .7),
        ),
      ),
    );
  }
}

class _CurvedBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final barTop = size.height - _barHeight;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, barTop, size.width, _barHeight),
      const Radius.circular(_barRadius),
    );

    final paintBar = Paint()..color = _barBg;
    final clearPaint = Paint()..blendMode = BlendMode.clear;

    final layerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.saveLayer(layerRect, Paint());

    canvas.drawRRect(rect, paintBar);

    final notchCenterX = size.width - _rightInset - (_fabSize / 2);
    final notchCenterY = barTop; // لبه‌ی بالای نوار

    canvas.drawCircle(Offset(notchCenterX, notchCenterY), _notchRadius, clearPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
