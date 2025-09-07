// lib/screens/ui_components/widgets/user_profile_widget.dart

import 'package:flutter/material.dart';
import 'package:labledger/models/auth_response_model.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

/// A widget that displays the current user's profile information
/// and provides a dropdown menu for account actions like settings and logout.
class UserProfileWidget extends StatelessWidget {
  final AuthResponse authResponse;
  final Color baseColor;
  final VoidCallback onLogout; // Callback function for logging out

  const UserProfileWidget({
    super.key,
    required this.authResponse,
    required this.baseColor,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data for clarity
    final String centerName = authResponse.centerDetail.centerName;
    final String userName =
        "${authResponse.firstName} ${authResponse.lastName}";
    final String userRole = authResponse.isAdmin
        ? "Admin Account"
        : "Standard User";

    // Get the first letter of the center name for the avatar
    final String avatarText = centerName.isNotEmpty
        ? centerName[0].toUpperCase()
        : "A";

    return TintedContainer(
      baseColor: baseColor,
      height: 80, // Let it size itself based on content
      width: null, // Let it size itself based on content
      radius: 50, // Rounded corners to match the design
      child: PopupMenuButton<String>(
        tooltip: "Account Settings",
        // Define the menu items
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          // A disabled header item to show who is logged in
          PopupMenuItem(
            enabled: false, // Makes it non-clickable
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userRole,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          // A (currently placeholder) settings button
          PopupMenuItem<String>(
            value: 'profile',
            child: Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                ),
                const SizedBox(width: 12),
                Text(
                  'Settings & Profile',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // The Logout Button
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, size: 18, color: Colors.red[400]),
                const SizedBox(width: 12),
                Text('Logout', style: TextStyle(color: Colors.red[400])),
              ],
            ),
          ),
        ],
        // Handle the selection
        onSelected: (String value) {
          switch (value) {
            case 'logout':
              onLogout(); // Execute the passed callback
              break;
            case 'profile':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile screen not implemented.'),
                ),
              );
              break;
            case 'theme':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme toggle not implemented.')),
              );
              break;
            case 'settings':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings screen not implemented.'),
                ),
              );
              break;
          }
        },
        // This is the widget the user sees and clicks on
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Welcome $userName", // Display Welcome message
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : baseColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      centerName, // Display the Center's Name
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : baseColor.withValues(alpha: 0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // User Avatar - Made larger and bolder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: baseColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: baseColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    avatarText,
                    style: TextStyle(
                      fontWeight: FontWeight.w800, // Extra bold
                      fontSize: 20, // Larger text
                      color: baseColor,
                    ),
                  ),
                ),
              ),
              // User Info Column

              // Removed dropdown arrow to make it invisible
            ],
          ),
        ),
      ),
    );
  }
}
