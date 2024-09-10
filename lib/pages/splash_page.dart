// ignore_for_file: use_build_context_synchronously

import 'package:calendar_app1/pages/user_list_page.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app1/pages/register_page.dart';
import 'package:calendar_app1/utils/constants.dart';

/// ログイン状態に応じてユーザーをリダイレクトするページ
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // widgetがmountするのを待つ
    await Future.delayed(Duration.zero);

    /// ログイン状態に応じて適切なページにリダイレクト
    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context)
          .pushAndRemoveUntil(RegisterPage.route(), (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const UserListPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}