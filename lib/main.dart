import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:park_finder/core/views/home_page.dart';
import 'package:park_finder/core/views/hidden_gem.dart';
import 'package:park_finder/core/views/login_page.dart';
import 'package:park_finder/core/controllers/reset_admin.dart';

// <-- Make sure this path is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Required to use Firebase services
  // await uploadJsonToFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Park Finder',
      debugShowCheckedModeBanner: false,
      // Start on SearchPage
      //home: ResetAdminPage(),
      home: LoginPage(),
    );
  }
}
