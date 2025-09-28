import 'package:flutter/material.dart';
import '../home_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});
  @override
  State<Splashscreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<Splashscreen> {
  //logic to show the screen for 3 screen and navigate to homescreen

  @override
  void initState() {
    super.initState();
    //navigate to homescreen after 3 screens
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF009b50),
      body: Center(
        child: Image(
          image: AssetImage("Assets/ParkFinderLogo.png"),
          height: 300,
          width: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
