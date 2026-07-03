import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labledger/main.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/models/center_detail_model_with_subscription.dart';
import 'package:labledger/screens/initials/login_screen.dart';
import 'package:labledger/screens/profile/user_list_screen.dart';
import 'package:labledger/screens/home/widgets/about_app_dialog.dart';
import 'package:labledger/screens/home/center_detail_dialog.dart';

class HomeMethods extends ChangeNotifier {
  final BuildContext context;
  final WidgetRef ref;

  HomeMethods(this.context, this.ref);

  String _selectedPeriod = "This Month";
  String get selectedPeriod => _selectedPeriod;

  void setSelectedPeriod(String period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      notifyListeners();
    }
  }

  Future<void> handleLogout() async {
    await const FlutterSecureStorage().delete(key: "access_token");
    await const FlutterSecureStorage().delete(key: "refresh_token");

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen(initialErrorMessage: "");
          },
        ),
      );
    }
  }

  void handleProfile(AuthResponse authResponse) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) {
            return UserListScreen(
              adminId: authResponse.isAdmin ? authResponse.id : 0,
            );
          },
        ),
      );
    }
  }

  void handleSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return const AboutAppDialog();
      },
    );
  }

  void showCenterDetailDialog(CenterDetail centerDetail) {
    showDialog(
      context: context,
      builder: (_) => CenterDetailDialog(centerDetail: centerDetail),
    );
  }

  void navigateTo(Widget screen) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }
}
