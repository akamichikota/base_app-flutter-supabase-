import 'package:flutter/material.dart';
import 'package:base_app/pages/user_list_page.dart';
import 'package:base_app/pages/login_page.dart'; // 追加
import 'package:base_app/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  static Route<void> route({bool isRegistering = false}) {
    return MaterialPageRoute(
      builder: (context) => const RegisterPage(),
    );
  }

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;
    try {
      final response = await supabase.auth.signUp(
        email: email, 
        password: password, 
        data: {'username': username}
      );

      if (response.error != null) {
        throw Exception('Failed to sign up: ${response.error!.message}');
      }

      // ユーザー登録後にprofilesテーブルにデータを追加
      final insertResponse = await supabase.from('profiles').insert({
        'id': response.user!.id, // ユーザーのIDを保存
        'username': username,
        'created_at': DateTime.now().toIso8601String(), // 作成日時を保存
      }).execute();
      debugPrint('Insert response: ${insertResponse.data}'); // デバッグプリントを追加

      // ユーザー一覧ページに遷移
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const UserListPage()),
        (route) => false,
      );
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登録'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                label: Text('メールアドレス'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return '必須';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            formSpacer,
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('パスワード'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return '必須';
                }
                if (val.length < 6) {
                  return '6文字以上';
                }
                return null;
              },
            ),
            formSpacer,
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                label: Text('ユーザー名'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return '必須';
                }
                // 日本語も含む文字（ひらがな、カタカナ、漢字）と英数字、アンダースコアを許可
                final isValid = RegExp(r'^[\w\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]{2,24}$').hasMatch(val);
                if (!isValid) {
                  return '3~24文字で入力してください（日本語、英数字、アンダースコアが使用可能）';
                }
                return null;
              },
            ),
            formSpacer,
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: const Text('登録'),
            ),
            formSpacer,
            TextButton(
              onPressed: () {
                Navigator.of(context).push(LoginPage.route());
              },
              child: const Text('すでにアカウントをお持ちの方はこちら'),
            )
          ],
        ),
      ),
    );
  }
}

extension on AuthResponse {
  get error => null;
}