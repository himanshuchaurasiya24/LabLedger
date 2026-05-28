import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/constants/urls.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/setup/pages/feature_page.dart';
import 'package:labledger/screens/setup/pages/intro_page.dart';
import 'package:labledger/screens/setup/pages/license_page.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';
import 'package:window_manager/window_manager.dart';

class SetupScreen extends ConsumerStatefulWidget {
  final AuthResponse authResponse;

  const SetupScreen({super.key, required this.authResponse});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  String? _licenseText;
  bool _isLicenseLoading = true;

  @override
  void initState() {
    setWindowBehavior(isForSetup: true);
    _fetchLicense();
    super.initState();
  }

  Future<void> _fetchLicense() async {
    try {
      final response = await AuthHttpClient.get(
        ref,
        '$globalBaseUrl${AppUrls.authLicense}',
      );
      final data = jsonDecode(response.body);
      setState(() {
        _licenseText = data['license_text'];
        _isLicenseLoading = false;
      });
    } catch (e) {
      setState(() {
        _licenseText =
            "Could not load the license agreement. Please try again later.";
        _isLicenseLoading = false;
      });
    }
  }

  Future<void> _acceptLicense() async {
    setState(() => _isLoading = true);
    try {
      await AuthHttpClient.patch(
        ref,
        '$globalBaseUrl${AppUrls.staffBase}/${widget.authResponse.id}/',
        body: jsonEncode({'has_accepted_license': true}),
      );

      if (!mounted) return;
      final updatedResponse = AuthResponse(
        access: widget.authResponse.access,
        refresh: widget.authResponse.refresh,
        success: widget.authResponse.success,
        isAdmin: widget.authResponse.isAdmin,
        isLocked: widget.authResponse.isLocked,
        hasAcceptedLicense: true,
        username: widget.authResponse.username,
        firstName: widget.authResponse.firstName,
        lastName: widget.authResponse.lastName,
        id: widget.authResponse.id,
        centerDetail: widget.authResponse.centerDetail,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(authResponse: updatedResponse),
        ),
      );
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          "Failed to accept license. Please try again.",
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  const IntroPage(),
                  const FeaturePage(
                    icon: Icons.receipt_long_rounded,
                    title: "Billing & Diagnostic Reports",
                    description:
                        "Seamlessly create patient bills, process samples, and generate professional diagnostic reports in one place.",
                  ),
                  const FeaturePage(
                    icon: Icons.people_alt_rounded,
                    title: "Referrals & Incentives",
                    description:
                        "Effortlessly track doctor and franchise referrals, and generate accurate automated incentives.",
                  ),
                  const FeaturePage(
                    icon: Icons.bar_chart_rounded,
                    title: "Analytics & Tracking",
                    description:
                        "Monitor your lab's performance with interactive charts, growth statistics, and real-time pending report tracking.",
                  ),
                  const FeaturePage(
                    icon: Icons.admin_panel_settings_rounded,
                    title: "Role-Based Management",
                    description:
                        "Secure your data with dedicated controls for Administrators, providing secure server configuration and audit logs.",
                  ),
                  const FeaturePage(
                    icon: Icons.chat_rounded,
                    title: "Messaging Integrations",
                    description:
                        "Instantly notify patients and doctors using our robust Local SMS Gateway and WhatsApp WebUI integrations.",
                  ),
                  const FeaturePage(
                    icon: Icons.domain_rounded,
                    title: "Multi-Center Management",
                    description:
                        "Manage multiple diagnostic centers, subscriptions, and quotas directly from a unified dashboard.",
                  ),
                  SetupLicensePage(
                    isLoading: _isLicenseLoading,
                    licenseText: _licenseText,
                  ),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await windowManager.close();
            },
            tooltip: "Close",
          ),
        ),
      ],
    ),
  ),
);
  }



  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentPage < 7)
            CustomElevatedButton(
              onPressed: _nextPage,
              icon: const Icon(Icons.arrow_forward),
              label: "Next",
              backgroundColor: Theme.of(context).colorScheme.primary,
              width: 140,
            )
          else
            CustomElevatedButton(
              onPressed:
                  _isLoading || _isLicenseLoading ? null : _acceptLicense,
              icon:
                  _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
              label: _isLoading ? "Accepting..." : "Accept & Continue",
              backgroundColor: Theme.of(context).colorScheme.primary,
              width: 240,
            ),
        ],
      ),
    );
  }
}
