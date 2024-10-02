import 'package:flutter/material.dart';
import 'package:mobile_app_mini_project/intro_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'career_search_page.dart';
import 'course_search.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/' : (context) => IntroScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/messages' : (context) => CareerSearchPage(),
        '/coursesearch' : (context) => CourseSearchPage(),// Placeholder for the home screen
      },
    );
  }
}


