import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  // متد برای اعتبار سنجی اطلاعات ورود
  void _login() {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous error message
    });

    String username = _usernameController.text;
    String password = _passwordController.text;

    // اینجا می‌توانید منطق اعتبار سنجی اطلاعات ورود را اضافه کنید.
    // در اینجا برای نمونه، فقط بررسی می‌کنیم که آیا فیلدها خالی هستند.
    if (username == 'admin' && password == 'password') {
      // اگر اطلاعات صحیح بود، وارد صفحه اصلی می‌شویم.
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/home'); // صفحه اصلی بعد از لاگین
    } else {
      // در صورت اشتباه بودن اطلاعات ورود، پیام خطا نمایش داده می‌شود.
      setState(() {
        _isLoading = false;
        _errorMessage = 'نام کاربری یا رمز عبور اشتباه است.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('صفحه ورود'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ورودی نام کاربری
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'نام کاربری',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // ورودی رمز عبور
            TextField(
              controller: _passwordController,
              obscureText: true, // برای مخفی کردن رمز عبور
              decoration: InputDecoration(
                labelText: 'رمز عبور',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // نمایش پیام خطا در صورت لزوم
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20),
            // دکمه ورود
            _isLoading
                ? CircularProgressIndicator() // در صورتی که در حال بارگذاری باشد، نمایش دادن چرخ لودینگ
                : ElevatedButton(
              onPressed: _login,
              child: Text('ورود'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
