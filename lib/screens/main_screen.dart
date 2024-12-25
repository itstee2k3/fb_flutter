import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'video_screen.dart'; // Import VideoScreen
import 'account_screen.dart';
import 'market_screen.dart';
import 'cart_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<String> _videoAssets = [
    'assets/sample_video.mp4',
    'assets/sample_video2.mp4',
    'assets/sample_video3.mp4',
    'assets/sample_video4.mp4',
  ];

  // Custom function to change the active and inactive colors for the BottomNavigationBar
  Color _getIconColor(int index) {
    return _currentIndex == index ? Colors.blue : Colors.grey;
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        // return VideoScreen(videoAssets: _videoAssets, initialIndex: 0);  // Correctly passing the videoAssets list
      case 2:
        return AccountScreen();
      case 3:
        return const MarketScreen();
      case 4:
        return const CartScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facebook Auth'),
      ),
      body: _getScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _getIconColor(0)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library, color: _getIconColor(1)),
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: _getIconColor(2)),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store, color: _getIconColor(3)),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: _getIconColor(4)),
            label: 'Cart',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        elevation: 10,
      ),
    );
  }
}
