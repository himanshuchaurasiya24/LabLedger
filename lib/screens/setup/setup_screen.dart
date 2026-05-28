import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/authentication/auth_http_client.dart';
import 'package:labledger/authentication/config.dart';
import 'package:labledger/constants/urls.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/screens/home/home_screen.dart';
import 'package:labledger/screens/ui_components/snackbar_utils.dart';

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
    setWindowBehavior(isForSetup:true);
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
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [_buildIntroPage(), _buildLicensePage()],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_rounded,
            size: 120,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 40),
          Text(
            "Welcome to LabLedger!",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            "Let's get you set up to manage your lab operations efficiently.",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLicensePage() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "End User License Agreement",
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _isLicenseLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(
                          _licenseText ?? "",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.6),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentPage == 0)
            ElevatedButton.icon(
              onPressed: _nextPage,
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Next"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _isLoading || _isLicenseLoading
                  ? null
                  : _acceptLicense,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isLoading ? "Accepting..." : "Accept & Continue"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
