import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/initials/login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.isAdmin,
  });
  final bool isAdmin;
  final int id;
  final String firstName;
  final String lastName;
  final String username;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void logout() {
    FlutterSecureStorage secureStorage = ref.read(secureStorageProvider);
    secureStorage.delete(key: 'access_token');
    secureStorage.delete(key: 'access_tokenn');
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

  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding,
        ),
        child: Column(
          children: [
            Row(
              children: [
                appIconName(
                  context: context,
                  firstName: "Lab",
                  secondName: "Ledger",
                  fontSize: 50,
                ),
                Row(
                  children: [
                    TopActionsTab(
                      title: "Overview",
                      selectedColor: Color(0xFF020711),
                      tabIndex: 1,
                      selectedtabIndex: currentIndex,
                      onTap: () => setState(() {
                        currentIndex = 1;
                      }),
                    ),
                    SizedBox(width: 20),
                    TopActionsTab(
                      title: "Bills",
                      selectedColor: Color(0xFF020711),
                      tabIndex: 2,
                      selectedtabIndex: currentIndex,
                      onTap: () => setState(() {
                        currentIndex = 2;
                      }),
                    ),
                    SizedBox(width: 20),
                    TopActionsTab(
                      title: "Doctors",
                      selectedColor: Color(0xFF020711),
                      tabIndex: 3,
                      selectedtabIndex: currentIndex,
                      onTap: () => setState(() {
                        currentIndex = 3;
                      }),
                    ),
                    SizedBox(width: 20),
                    TopActionsTab(
                      title: "Reports",
                      selectedColor: Color(0xFF020711),
                      tabIndex: 4,
                      selectedtabIndex: currentIndex,
                      onTap: () => setState(() {
                        currentIndex = 4;
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TopActionsTab extends StatelessWidget {
  final String title;
  final Color selectedColor;
  final int tabIndex;
  final int selectedtabIndex;
  final void Function() onTap;
  const TopActionsTab({
    super.key,
    required this.title,
    required this.tabIndex,
    required this.selectedColor,
    required this.selectedtabIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        backgroundColor: tabIndex == selectedtabIndex
            ? selectedColor
            : Color(0xFFFFFFFF).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(30),
        height: 60,
        width: 180,
        child: Center(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
