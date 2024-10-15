import 'package:firebase_core/firebase_core.dart';
import 'chatlistscreen.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:mobile_app_mini_project/intro_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'career_search_page.dart';
import 'course_search.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';
import 'edit_screen.dart';
import 'intro_screen.dart';
import 'chat_screen.dart';
import 'other_profile.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/': (context) => IntroScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/messages': (context) => SearchScreen(),
        '/postcreationpage': (context) => AddPostScreen(),
        '/chatbot': (context) => ChatbotScreen(), 
        '/profilescreen': (context) => ProfileScreen(),
        '/editprofile': (context) => EditProfileScreen(),
        '/chatlistscreen' : (context) => ChatListScreen(),
        '/otherprofile': (context) {
          final String userId = ModalRoute.of(context)!.settings.arguments as String;
          return OtherProfileScreen(userId: userId);
        },
      },
    );
  }
}
