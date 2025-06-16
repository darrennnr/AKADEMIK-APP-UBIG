import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'dart:async';
import 'package:myapp/pages/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            ///***If you have exported images you must have to copy those images in assets/images directory.
            Image(
              image: AssetImage("images/Logo.png"),
              height: 100,
              width: 140,
              fit: BoxFit.contain,
            ),
            Text(
              "AKADEMIK",
              textAlign: TextAlign.start,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                fontSize: 32,
                color: Color(0xff3419e0),
              ),
            ),
            Text(
              "APP",
              textAlign: TextAlign.start,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.normal,
                fontSize: 32,
                color: Color(0xff3635ff),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
