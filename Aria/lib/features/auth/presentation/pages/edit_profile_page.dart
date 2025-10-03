  // lib/features/auth/presentation/pages/edit_profile_page.dart
  import 'dart:io';
  import 'package:dio/dio.dart';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:provider/provider.dart';

  import 'package:aria/features/auth/presentation/controllers/auth_controller.dart';
  import 'package:aria/shared/styles/colors.dart';
  import 'package:aria/shared/widgets/primary_button.dart';

  class EditProfilePage extends StatefulWidget {
    const EditProfilePage({Key? key}) : super(key: key);

    @override
    State<EditProfilePage> createState() => _EditProfilePageState();
  }

  class _EditProfilePageState extends State<EditProfilePage> {
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final _picker = ImagePicker();
    File? pickedImage;

    @override
    void initState() {
      super.initState();
      final auth = context.read<AuthController>();
      if (auth.currentUser != null) {
        firstCtrl.text = auth.currentUser!.firstName ?? '';
        lastCtrl.text = auth.currentUser!.lastName ?? '';
      }
    }

    @override
    void dispose() {
      firstCtrl.dispose();
      lastCtrl.dispose();
      super.dispose();
    }

    Future<void> _pickAvatar() async {
      try {
        final XFile? file = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (!mounted) return;
        if (file != null) {
          setState(() => pickedImage = File(file.path));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Text('عدم دسترسی به گالری یا خطای انتخاب تصویر: $e',
                  style: const TextStyle(color: Colors.white)),
            ),
            backgroundColor: AppColors.redPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    Future<void> _submit() async {
      final auth = context.read<AuthController>();

      MultipartFile? avatar;
      if (pickedImage != null) {
        avatar = await MultipartFile.fromFile(
          pickedImage!.path,
          filename: 'avatar.jpg',
        );
      }

      final ok = await auth.updateProfile(
        firstName: firstCtrl.text.trim().isEmpty ? null : firstCtrl.text.trim(),
        lastName: lastCtrl.text.trim().isEmpty ? null : lastCtrl.text.trim(),
        profileImage: avatar,
      );

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: const Text(
                'پروفایل با موفقیت آپدیت شد',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } else if (auth.errorText != null && auth.errorText!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                auth.errorText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            backgroundColor: AppColors.redPrimary,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }


    InputDecoration _inputDecoration(BuildContext context, String hint) {
      final primary = Theme.of(context).primaryColor;
      return InputDecoration(
        hintText: hint,

        hintStyle: const TextStyle(
          color: Colors.white54,
          fontSize: 14,
          fontFamily: 'customy',
        ),
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grayBlack),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grayBlack),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        isDense: true,
      );
    }

    @override
    Widget build(BuildContext context) {
      final auth = context.watch<AuthController>();
      final primary = Theme.of(context).primaryColor;

      return Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          elevation: 0,
          title: const Text(
            'ایجاد پروفایل',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ListView(
            children: [
              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: primary, width: 3),
                        ),
                      ),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.black,
                        backgroundImage: pickedImage != null
                            ? FileImage(pickedImage!)
                            : (auth.currentUser?.profileImage != null
                            ? NetworkImage(auth.currentUser!.profileImage!)
                            : null) as ImageProvider?,
                        child: pickedImage == null && auth.currentUser?.profileImage == null
                            ? const Icon(Icons.person, color: Colors.white70, size: 40)
                            : null,
                      ),

                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: InkWell(
                          onTap: _pickAvatar,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: primary,
                            child: const Icon(Icons.edit,
                                size: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'لطفاً جهت تکمیل حساب خود، اطلاعات زیر را تکمیل کنید.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: firstCtrl,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
          fontFamily: 'customy',
                  ),
                  decoration: _inputDecoration(context, 'نام'),
                ),
              ),
              const SizedBox(height: 12),

              Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: lastCtrl,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  enableSuggestions: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamilyFallback: ['Vazirmatn', 'Tahoma', 'Arial'],
                  ),
                  decoration: _inputDecoration(context, 'نام خانوادگی'),
                ),
              ),

              const SizedBox(height: 20),

              PrimaryButton(
                text: auth.isLoading ? '...' : 'ثبت پروفایل',
                onPressed: auth.isLoading ? null : _submit,
                backgroundColor: primary,
                fontWeight: FontWeight.w400,
                height: 45,
                borderRadius: 12,
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      );
    }
  }
