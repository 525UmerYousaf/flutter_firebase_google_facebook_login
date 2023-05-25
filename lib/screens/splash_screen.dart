import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../provider/sign_in_provider.dart';
import '../utils/config.dart';
import './login_screen.dart';
import './home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    final sp = context.read<SignInProvider>();
    super.initState();
    //  Creating a timer of 2 seconds.
    //  It is time in which value will be fetched from device
    //  otherwise user would be send to next screen.
    Timer(
      const Duration(seconds: 2),
      () {
        sp.isSignedIn == false
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (coontext) => const LoginScreen(),
                ),
              )
            : Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (coontext) => const HomeScreen(),
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Image(
            image: AssetImage(Config.app_icon),
            height: 80,
            width: 80,
          ),
        ),
      ),
    );
  }
}
