import 'dart:async';
import 'package:aria/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aria/features/home/presentation/pages/home_screen.dart'; // صفحه اصلی

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Dio dio = Dio();
  bool isLoading = true;
  Color loadingColor = Colors.blue;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  _checkConnection() async {
    try {
      Response response = await dio.get('https://www.google.com');
      if (response.statusCode == 200) {
        _checkJWT();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  _checkJWT() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/home'); // Use the router here
      });
    } else {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
      });
    }
  }

  _retryConnection() {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    _checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/theme/yellow.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Text(
                      'آریا گرد',
                      style: TextStyle(
                        fontSize: 120,
                        fontFamily: 'jahan',
                        color: Colors.white,
                      ),
                    ),


                    Transform.translate(
                      offset: Offset(0, -25),
                      child: Text(
                        'ایران، سرزمین افسانه‌ها',
                        style: TextStyle(
                          fontFamily: 'Customy',
                          color: AppColors.gray,
                          fontSize: 20,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.23),

                if (isLoading)
                  TweenAnimationBuilder<Color?>(
                    duration: Duration(seconds: 1),
                    tween: ColorTween(begin: Colors.blue, end: loadingColor),
                    builder: (context, color, child) {
                      return SvgPicture.asset(
                        'assets/images/svg/loading.svg',
                        color: color,
                        width: 125,
                        height: 125,
                      );
                    },
                  ),

                if (hasError || (!hasError && !isLoading)) SizedBox(height: 20),

                if (hasError)
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'لطفا اتصال به اینترنت دستگاه خود را چک کنید و دوباره تلاش کنید',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Customy',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _retryConnection,
                        child: Text(
                          'تلاش دوباره',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Customy',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                          elevation: 1,
                        ),
                      ),
                    ],
                  ),

                if (!hasError && !isLoading)
                  ElevatedButton(
                    onPressed: _retryConnection,
                    child: Text('تلاش دوباره'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Customy',
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
