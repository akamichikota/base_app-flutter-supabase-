import 'package:calendar_app1/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabaseの初期化
  await Supabase.initialize(
    url: 'https://gjnttoyjgnfeafciekxz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdqbnR0b3lqZ25mZWFmY2lla3h6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU4Njc4MDIsImV4cCI6MjA0MTQ0MzgwMn0.hH-II1wpgQiOQYcZ8FsDgx7RFIcUoKprQKk6dk1KH5Q',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'カレンダーアプリ',
      home: SplashPage(), // RegisterPageを表示するように変更
    );
  }
}