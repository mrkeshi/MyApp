import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:xml/xml.dart';
import 'package:provider/provider.dart';

import 'package:aria/shared/styles/colors.dart';
import 'package:aria/shared/widgets/primary_button.dart';

import '../controller/province_controller.dart';

class IranMapPainter extends CustomPainter {
  final Map<String, Path> provincePaths;
  final String? selectedId;
  final Color primary;

  IranMapPainter(this.provincePaths, this.selectedId, this.primary);

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.black;

    final scale = size.width / 600;
    canvas.scale(scale);

    provincePaths.forEach((id, path) {
      fillPaint.color = (id == selectedId) ? primary : AppColors.gray;
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    });
  }

  @override
  bool shouldRepaint(covariant IranMapPainter oldDelegate) {
    return oldDelegate.selectedId != selectedId || oldDelegate.primary != primary;
  }
}

class IranMapScreen extends StatefulWidget {
  const IranMapScreen({super.key});

  @override
  State<IranMapScreen> createState() => _IranMapScreenState();
}

class _IranMapScreenState extends State<IranMapScreen> {
  Map<String, Path> provincePaths = {};
  String? selectedId;

  final Map<String, String> provincesFa = const {
    "IR-6": "بوشهر",
    "IR-2": "فارس",
    "IR-4": "اصفهان",
    "IR-7": "تهران",
    "IR-10": "خوزستان",
    "IR-15": "کرمان",
    "IR-13": "سیستان و بلوچستان",
    "IR-1": "آذربایجان شرقی",
    "IR-14": "آذربایجان غربی",
    "IR-31": "خراسان شمالی",
    "IR-30": "خراسان رضوی",
    "IR-29": "خراسان جنوبی",
    "IR-19": "گیلان",
    "IR-21": "مازندران",
    "IR-27": "گلستان",
    "IR-18": "کهگیلویه و بویراحمد",
    "IR-20": "لرستان",
    "IR-5": "ایلام",
    "IR-16": "کردستان",
    "IR-17": "کرمانشاه",
    "IR-11": "زنجان",
    "IR-28": "قزوین",
    "IR-12": "سمنان",
    "IR-22": "مرکزی",
    "IR-24": "همدان",
    "IR-26": "قم",
    "IR-25": "یزد",
    "IR-23": "هرمزگان",
    "IR-8": "چهارمحال و بختیاری",
    "IR-3": "اردبیل",
    "IR-32": "البرز",
  };

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    final svgStr = await rootBundle.loadString("assets/svg/iran.svg");
    final document = XmlDocument.parse(svgStr);

    final paths = <String, Path>{};
    for (final pathElement in document.findAllElements('path')) {
      final id = pathElement.getAttribute('id') ?? "";
      final d = pathElement.getAttribute('d');
      if (d != null && id.isNotEmpty) {
        final path = parseSvgPath(d);
        paths[id] = path;
      }
    }

    setState(() {
      provincePaths = paths;
    });
  }

  void _handleTap(Offset localPos, Size size) {
    final scale = size.width / 600;
    final tappedPoint = localPos / scale;

    for (var entry in provincePaths.entries) {
      if (entry.value.contains(tappedPoint)) {
        setState(() {
          selectedId = entry.key; // مثل "IR-2"
        });
        break;
      }
    }
  }

  void _showSnack(BuildContext context, String message, Color background) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        backgroundColor: background,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final c = context.watch<ProvinceController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "انتخاب استان",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const Text(
              "یک استان جهت گردش انتخاب کنید",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxWidth);
                    return GestureDetector(
                      onTapDown: (details) => _handleTap(details.localPosition, size),
                      child: CustomPaint(
                        size: size,
                        painter: IranMapPainter(provincePaths, selectedId, primary),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (selectedId != null)
              Column(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "استان انتخاب شده: ",
                          style: TextStyle(color: Colors.white, fontSize: 17, fontFamily: 'customy'),
                        ),
                        TextSpan(
                          text: provincesFa[selectedId] ?? "",
                          style: TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'customy'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: PrimaryButton
                      (
                      text: c.loading ? "در حال ذخیره…" : "ذخیره",
                      onPressed: c.loading
                          ? null
                          : () async {
                        if (selectedId == null) {
                          _showSnack(context, 'لطفاً یک استان انتخاب کنید', AppColors.redPrimary);
                          return;
                        }

                        await context.read<ProvinceController>().changeProvinceFromCode(selectedId!);

                        if (!mounted) return;

                        final pc = context.read<ProvinceController>();
                        if (pc.errorText != null) {
                          _showSnack(context, pc.errorText!.toString(), AppColors.redPrimary);
                        } else {
                          _showSnack(context, 'استان با موفقیت ذخیره شد', primary);
                          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                        }
                      },
                      backgroundColor: primary,
                      fontWeight: FontWeight.w400,
                      height: 50,
                      borderRadius: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
