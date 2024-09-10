import 'package:flutter/material.dart';
import 'package:calendar_app1/models/profile.dart';
import 'package:calendar_app1/utils/constants.dart';
import 'package:calendar_app1/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  late Future<List<Profile>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<Profile>> _fetchUsers() async {
    try {
      final response = await supabase.from('profiles').select().execute();
      debugPrint('Response data: ${response.data}'); // デバッグプリントを追加

      // エラーチェック
      if (response.error != null) {
        // エラーがあった場合は例外を投げる
        throw Exception('Failed to load users: ${response.error!.message}');
      }

      // データが空かどうかをチェック
      if (response.data == null) {
        throw Exception('No data received from the server');
      }

      // データがある場合、リストに変換
      final List<dynamic> usersList = response.data;
      return usersList.map((user) => Profile.fromMap(user)).toList();
    } catch (e) {
      // エラーハンドリング
      debugPrint('Error fetching users: $e');
      rethrow;  // エラーを再度投げることでFutureBuilderでキャッチさせる
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    // ログアウト後にログインページに遷移する処理
    Navigator.of(context).pushAndRemoveUntil(
      LoginPage.route(),
      (route) => false,
    );
  }

  Future<void> _showEditDialog(Profile user) async {
    final TextEditingController _usernameController = TextEditingController(text: user.username);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ユーザー名を編集'),
          content: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'ユーザー名'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('保存'),
              onPressed: () async {
                await _updateUsername(user.id, _usernameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUsername(String userId, String newUsername) async {
    try {
      final response = await supabase
          .from('profiles')
          .update({'username': newUsername})
          .eq('id', userId)
          .execute();

      if (response.error != null) {
        throw Exception('Failed to update username: ${response.error!.message}');
      }

      // ユーザーリストを再取得して更新
      setState(() {
        _usersFuture = _fetchUsers();
      });
    } catch (e) {
      debugPrint('Error updating username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Profile>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // エラーが発生した場合
            return Center(child: Text('エラー: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // ユーザーリストが空の場合
            return const Center(child: Text('ユーザーがいません'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text(user.id),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

extension on PostgrestResponse {
  get error => null;
}