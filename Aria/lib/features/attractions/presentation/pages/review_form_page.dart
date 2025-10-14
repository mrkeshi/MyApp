import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/styles/colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../presentation/controller/attractions_controller.dart';

class ReviewFormSheet extends StatefulWidget {
  final int attractionId;
  const ReviewFormSheet({super.key, required this.attractionId});

  @override
  State<ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<ReviewFormSheet> {
  int rating = 0;
  final textCtrl = TextEditingController();
  bool submitting = false;

  final _sheetMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    textCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  void _showSnack({required String message, required Color bg}) {
    final snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      duration: const Duration(seconds: 2),
    );
    final m = _sheetMessengerKey.currentState;
    if (m != null) {
      m.removeCurrentSnackBar();
      m.showSnackBar(snack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final auth = context.watch<AuthController>();
    final first = auth.currentUser?.firstName?.trim() ?? '';
    final last = auth.currentUser?.lastName?.trim() ?? '';
    final displayName = (first.isNotEmpty || last.isNotEmpty) ? '$first $last'.trim() : 'کاربر';
    final photoUrl = auth.currentUser?.profileImage ?? '';
    final canSubmit = rating > 0 && textCtrl.text.trim().isNotEmpty && !submitting;

    return ScaffoldMessenger(
      key: _sheetMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(
                color: AppColors.menuBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ثبت نظر جدید',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: primary, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.white24,
                                      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                                      child: photoUrl.isEmpty
                                          ? Text(
                                        displayName.isNotEmpty ? displayName.characters.first : '؟',
                                        style: const TextStyle(color: Colors.white),
                                      )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    displayName,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                children: List.generate(5, (i) {
                                  final filled = i < rating;
                                  return GestureDetector(
                                    onTap: () => setState(() => rating = i + 1),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 1),
                                      child: Icon(
                                        filled ? Icons.star : Icons.star_border,
                                        size: 28,
                                        color: primary,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFC8C8C8)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: TextField(
                              controller: textCtrl,
                              maxLines: 6,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'هرچه دل تنگت می‌خواهد اینجا بنویس',
                                hintStyle: TextStyle(color: Color(0xFFC8C8C8), fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: canSubmit
                            ? () async {
                          final c = context.read<AttractionsController>();
                          setState(() => submitting = true);
                          try {
                            final ok = await c.submitReview(
                              widget.attractionId,
                              rating: rating,
                              comment: textCtrl.text.trim(),
                            );
                            if (!mounted) return;
                            if (ok) {
                              _showSnack(message: 'نظر شما با موفقیت ثبت شد', bg: primary);
                              await Future.delayed(const Duration(milliseconds: 350));
                              Navigator.pop(context, true);
                            } else {
                              _showSnack(message: c.error ?? 'خطا در ارسال نظر', bg: Colors.red);
                            }
                          } catch (_) {
                            if (!mounted) return;
                            _showSnack(message: 'خطا در ارسال نظر', bg: Colors.red);
                          } finally {
                            if (mounted) setState(() => submitting = false);
                          }
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: primary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          submitting ? '...' : 'ثبت نظر',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
