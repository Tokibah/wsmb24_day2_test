import 'dart:io';
import 'dart:math';

import 'package:d2_wsf24_rider/Modal/rider_repo.dart';
import 'package:d2_wsf24_rider/Welcome/launchscreen.dart';
import 'package:d2_wsf24_rider/Welcome/loginpage.dart';
import 'package:d2_wsf24_rider/main.dart';
import 'package:d2_wsf24_rider/pagetransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CaptchaPage extends StatefulWidget {
  const CaptchaPage({super.key, required this.image, required this.newRider});

  final Rider newRider;
  final File image;

  @override
  State<CaptchaPage> createState() => _CaptchaPageState();
}

class _CaptchaPageState extends State<CaptchaPage> {
  String capthcaText = '';

  String char =
      'cfghjkdfovicjnbswvehjfkKJNBWEDFHCJXKLOPSWKJENBHFowijhebdfhvjckl';

  final _capController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generatecaptha();
  }

  void _generatecaptha() {
    String generateCap = '';
    for (int i = 0; i < 5; i++) {
      final index = Random().nextInt(char.length);
      generateCap += char[index];
    }
    int capTail = Random().nextInt(100);
    capthcaText = '$generateCap$capTail';
    setState(() {});
  }

  void _submit() async {
    if (_capController.text.trim() == capthcaText) {
      await Rider.addRider(widget.newRider);
      Rider.uploadImage(widget.image, widget.newRider.idLabel);

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LaunchScreen()));
      Navigator.push(context, SizeRoute(page: const LogInPage()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Wrong')));
      _generatecaptha();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Please input the text below:',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        Container(
          height: 100.sp,
          width: 300.w,
          decoration: BoxDecoration(
              color: ThemeProvider.honeydew, border: Border.all()),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Transform.rotate(angle: 10,
              child: Text(
                '$capthcaText',
                style: TextStyle(
                    fontSize: 30.sp,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 2),
              ),
            ),
            
          ]),
        ),
        Padding(
          padding: EdgeInsets.all(20.sp),
          child: TextField(
            controller: _capController,
            decoration: InputDecoration(hintText: 'Type here..'),
            textAlign: TextAlign.center,
          ),
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeProvider.trustColor,
            ),
            onPressed: _submit,
            child: Text('Submit'))
      ]),
    );
  }
}
