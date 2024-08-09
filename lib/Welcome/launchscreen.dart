import 'package:d2_wsf24_rider/Welcome/loginpage.dart';
import 'package:d2_wsf24_rider/Welcome/signuppage.dart';
import 'package:d2_wsf24_rider/main.dart';
import 'package:d2_wsf24_rider/pagetransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  final opacity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.honeydew,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('KONGSI\nKERETA',
              textAlign: TextAlign.center,
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dashed,
                  decorationColor: ThemeProvider.popColor,
                  decorationThickness: 2,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold)),
          Icon(
            Icons.energy_savings_leaf_outlined,
            size: 350,
          ),
          Text('Enjoy your free hassle journey',
              style: TextStyle(fontSize: 25.sp)),
          SizedBox(height: 40.h),
          SizedBox(
            width: 250.w,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeProvider.trustColor),
              onPressed: () {
                Navigator.push(context, SizeRoute(page: const SignUpPage()));
              },
              child: Text(
                'SIGN UP',
                style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, SizeRoute(page: const LogInPage()));
            },
            child: Text(
              'Log in',
              style: TextStyle(fontSize: 20.sp, color: Colors.black38),
            ),
          ),
        ]),
      ),
    );
  }
}
