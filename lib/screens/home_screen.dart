import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/login_screen.dart';
import 'package:window_manager/window_manager.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  void setWindowBehavior({bool? isForLogin}) async {
    bool isLogin = isForLogin ?? false;
    if (!isLogin) {
      await windowManager.setSize(const Size(1280, 720), animate: true);
      await windowManager.center();
      await windowManager.setSkipTaskbar(false);
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    } else {
      await windowManager.setSize(const Size(700, 350), animate: true);
      await windowManager.center();
      await windowManager.setSkipTaskbar(true);
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }
  }

  void logout() {
    FlutterSecureStorage secureStorage = ref.read(secureStorageProvider);
    debugPrint(secureStorage.read(key: 'access_token').toString());
    secureStorage.delete(key: 'access_token');
    setWindowBehavior(isForLogin: true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    setWindowBehavior();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          IconButton(
            onPressed: () {
              logout();
            },
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Center(child: Text("Home Screen")),
    );
  }
}
