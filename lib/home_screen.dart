import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // Home is already the current screen
        break;
      case 1:
        Navigator.pushNamed(context, '/chatbot');
        break;
      case 2:
        Navigator.pushNamed(context, '/coursesearch');
        break;
      case 3:
        Navigator.pushNamed(context, '/messages');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("CareerPath",),backgroundColor: Color(0xffa1c4fd)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xffa1c4fd),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.black, size: 30),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black, size: 30),
            label: 'Course',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.message, color: Colors.black, size: 30),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black, size: 30),
            label: 'Profile',
          ),

        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
