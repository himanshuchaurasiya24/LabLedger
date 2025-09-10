import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/providers/user_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/profile/user_edit_screen.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({
    super.key,
    required this.baseColor,
    required this.adminId,
  });
  final Color baseColor;
  final int adminId;
  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  // --- 🎨 Updated Color Logic ---

  /// Background color
  Color get backgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Updated to use standard .withOpacity()
    return isDark
        ? widget.baseColor.withValues(alpha: 0.8) // darker bg in dark mode
        : widget.baseColor.withValues(alpha: 0.1); // lighter bg in light mode
  }

  /// Text color - Use accent color at full opacity in light mode
  Color get importantTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Colors.white; // Keep white for dark mode
    } else {
      // Use accent color with guaranteed full opacity.
      // Updated to use standard .withOpacity()
      return widget.baseColor.withValues(alpha: 1.0);
    }
  }

  Color get normalTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white70 : Colors.black87;
  }

  Color get accentFillColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Updated to use standard .withOpacity()
    return isDark
        ? widget.baseColor.withValues(alpha: 0.6)
        : widget.baseColor.withValues(alpha: 0.15);
  }

  /// Bar color for the breakdown charts
  Color get barColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Updated to use standard .withOpacity()
    return isDark
        ? Colors.white.withValues(alpha: 0.9)
        : widget.baseColor; // Use accent color for bars in light mode
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersDetailsProvider);
    final size = MediaQuery.of(context).size;
    return WindowScaffold(
      child: usersAsync.when(
        data: (users) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: size.width > initialWindowWidth ? 2.8 : 2.3,
              crossAxisSpacing: defaultWidth,
              mainAxisSpacing: defaultHeight,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(
                      builder: (context) {
                        return UserEditScreen(
                          targetUserId: users[index].id,
                          isAdmin: true,
                          themeColor: Theme.of(context).colorScheme.secondary,
                        );
                      },
                    ),
                  );
                },
                child: TintedContainer(
                  baseColor: Colors.teal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            users[index].username,
                            style: TextStyle(
                              color: importantTextColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 100,
                            decoration: BoxDecoration(
                              color: widget.baseColor.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(
                                defaultRadius * 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                users[index].isAdmin ? "Admin" : "User",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${users[index].firstName} ${users[index].lastName}",
                        style: TextStyle(
                          color: importantTextColor,
                          fontSize: 18,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        users[index].phoneNumber,
                        style: TextStyle(
                          color: importantTextColor,
                          fontSize: 18,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        users[index].address,
                        style: TextStyle(
                          color: importantTextColor,
                          fontSize: 18,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        users[index].email,
                        style: TextStyle(
                          color: importantTextColor,
                          fontSize: 18,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text(
            "Some error occured while fetching the list...",
            style: TextStyle(fontSize: 30, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
