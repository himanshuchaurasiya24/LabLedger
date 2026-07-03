import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/constants/urls.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';

class SetupMethods extends ChangeNotifier {
  final BuildContext context;
  final WidgetRef ref;
  final AuthResponse authResponse;

  final PageController pageController = PageController();
  int currentPage = 0;
  bool isLoading = false;
  String? licenseText;
  bool isLicenseLoading = true;

  SetupMethods(this.context, this.ref, this.authResponse) {
    _fetchLicense();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    currentPage = index;
    notifyListeners();
  }

  Future<void> _fetchLicense() async {
    try {
      final response = await AuthHttpClient.get(
        ref,
        '$globalBaseUrl${AppUrls.authLicense}',
      );
      final data = jsonDecode(response.body);
      licenseText = data['license_text'];
      isLicenseLoading = false;
      notifyListeners();
    } catch (e) {
      licenseText =
          "Could not load the license agreement. Please try again later.";
      isLicenseLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptLicense() async {
    isLoading = true;
    notifyListeners();
    
    try {
      await AuthHttpClient.patch(
        ref,
        '$globalBaseUrl${AppUrls.staffBase}/${authResponse.id}/',
        body: jsonEncode({'has_accepted_license': true}),
      );

      if (!context.mounted) return;
      final updatedResponse = AuthResponse(
        access: authResponse.access,
        refresh: authResponse.refresh,
        success: authResponse.success,
        isAdmin: authResponse.isAdmin,
        isLocked: authResponse.isLocked,
        hasAcceptedLicense: true,
        username: authResponse.username,
        firstName: authResponse.firstName,
        lastName: authResponse.lastName,
        id: authResponse.id,
        centerDetail: authResponse.centerDetail,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(authResponse: updatedResponse),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(
          context,
          "Failed to accept license. Please try again.",
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
