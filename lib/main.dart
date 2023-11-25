import 'dart:async';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';
import 'package:rakshak_reet/home.dart';
import 'package:rakshak_reet/singup.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await Future.delayed(const Duration(microseconds: 1));
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => SplashScreen(),
        "/splash_screen": (context) => SplashScreen(),
        "/signUp_screen": (context) => SignUp(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    whereToGo();
  }

  void whereToGo() {
    Timer(Duration(seconds: 4), () async {
      // Check if authToken is available in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('authToken');

      if (authToken == null) {
        // If authToken is null, navigate to SignUp
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignUp()));
      } else {
        // If authToken is available, navigate to HomePage
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width * 1,
                child: Image.asset('assets/images/rakshak_reet.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
