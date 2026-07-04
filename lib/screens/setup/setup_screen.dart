import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/screens/setup/pages/feature_page.dart';
import 'package:labledger/screens/setup/pages/intro_page.dart';
import 'package:labledger/screens/setup/pages/license_page.dart';
import 'package:labledger/screens/ui_components/custom_elevated_button.dart';
import 'package:window_manager/window_manager.dart';
import 'package:labledger/screens/setup/methods/setup_methods.dart';
import 'package:labledger/constants/constants.dart';

class SetupScreen extends ConsumerStatefulWidget {
  final AuthResponse authResponse;

  const SetupScreen({super.key, required this.authResponse});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  late SetupMethods _methods;

  @override
  void initState() {
    setWindowBehavior(isForSetup: true);
    _methods = SetupMethods(context, ref, widget.authResponse);
    super.initState();
  }

  @override
  void dispose() {
    _methods.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _methods,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _methods.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: _methods.onPageChanged,
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
                          isLoading: _methods.isLicenseLoading,
                          licenseText: _methods.licenseText,
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
    ),))
);
  }



  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(xxlargePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_methods.currentPage < 7)
            CustomElevatedButton(
              onPressed: _methods.nextPage,
              icon: const Icon(Icons.arrow_forward),
              label: "Next",
              backgroundColor: Theme.of(context).colorScheme.primary,
              width: 140,
            )
          else
            CustomElevatedButton(
              onPressed:
                  _methods.isLoading || _methods.isLicenseLoading ? null : _methods.acceptLicense,
              icon:
                  _methods.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
              label: _methods.isLoading ? "Accepting..." : "Accept & Continue",
              backgroundColor: Theme.of(context).colorScheme.primary,
              width: 240,
            ),
        ],
      ),
    );
  }
}
