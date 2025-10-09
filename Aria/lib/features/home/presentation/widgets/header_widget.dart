import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aria/features/auth/domain/entities/user.dart';
import 'package:aria/features/province/domain/entities/province.dart';
import 'package:aria/features/auth/presentation/controllers/auth_controller.dart';
import 'package:aria/features/province/presentation/controller/province_controller.dart';
import '../controller/audio_controller.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Provider.of<AuthController>(context);
    final provinceController = Provider.of<ProvinceController>(context);
    final audioController = Provider.of<AudioController>(context);

    User? user = authController.currentUser;
    Province? province = provinceController.province;
    final provinceText = province?.nameFa != null
        ? 'بزنیم بریم ${province!.nameFa} بگردیم'
        : 'استان انتخاب نشده';

    return Transform.translate(
      offset: const Offset(0, -8),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          color: theme.colorScheme.background,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedCircleAvatar(
                    imageUrl: user?.profileImage,
                    radius: 22,
                    borderColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provinceText,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Customy',
                          color: theme.colorScheme.onBackground.withOpacity(0.8),
                          fontSize: 13,
                          wordSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user?.firstName ?? 'نام'} ${user?.lastName ?? 'کاربر'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Customy',
                          color: theme.colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => audioController.toggleMusic(),
                icon: Icon(
                  audioController.isPlaying
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: theme.colorScheme.onBackground,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------
// Animated Skeleton CircleAvatar
// -------------------------
class AnimatedCircleAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final Color borderColor;

  const AnimatedCircleAvatar({
    super.key,
    this.imageUrl,
    this.radius = 22,
    required this.borderColor,
  });

  @override
  State<AnimatedCircleAvatar> createState() => _AnimatedCircleAvatarState();
}

class _AnimatedCircleAvatarState extends State<AnimatedCircleAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: widget.borderColor, width: 2),
      ),
      child: widget.imageUrl != null
          ? CircleAvatar(
        radius: widget.radius,
        backgroundImage: NetworkImage(widget.imageUrl!),
      )
          : AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CircleAvatar(
            radius: widget.radius,
            backgroundColor:
            Colors.grey.shade700.withOpacity(_animation.value),
            child: const Icon(Icons.person, color: Colors.white54, size: 24),
          );
        },
      ),
    );
  }
}
