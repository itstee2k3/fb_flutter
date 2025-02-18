import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'package:provider/provider.dart';
import '../provider/post_provider.dart'; // Import PostProvider

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook-like Interface',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Trực tiếp cung cấp MultiProvider mà không cần kiểm tra login status
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => PostProvider()), // Cung cấp PostProvider
          // Thêm các provider khác nếu cần
        ],
        child: const MainScreen(),
      ),
    );
  }
}