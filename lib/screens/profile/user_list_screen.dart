import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/providers/user_provider.dart';
import 'package:labledger/screens/initials/window_scaffold.dart';
import 'package:labledger/screens/profile/user_edit_screen.dart';
import 'package:labledger/screens/ui_components/tinted_container.dart';

class UserListScreen extends ConsumerStatefulWidget {
  // 1. 'baseColor' has been removed from the constructor.
  const UserListScreen({super.key, required this.adminId});

  final int adminId;
  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  // 2. The previous color getter methods have been removed.

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersDetailsProvider);
    final size = MediaQuery.of(context).size;
    return WindowScaffold(
      child: usersAsync.when(
        data: (users) {
          return GridView.builder(
            // Original layout and spacing are preserved.
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: size.width > initialWindowWidth ? 2.8 : 2.3,
              crossAxisSpacing: defaultWidth,
              mainAxisSpacing: defaultHeight,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              // --- 3. DYNAMIC COLOR LOGIC STARTS HERE ---
              final user = users[index];
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;

              // The base color is now determined by the user's locked status.
              final cardColor = user.isLocked
                  ? Colors.red.shade700
                  : theme.colorScheme.secondary;

              // The text color is determined based on the theme for best readability.
              final textColor = isDark ? Colors.white : cardColor;
              // --- DYNAMIC COLOR LOGIC ENDS HERE ---

              return InkWell(
                onTap: () {
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(
                      builder: (context) {
                        return UserEditScreen(
                          targetUserId: user.id,
                          isAdmin: true,
                          // Pass the dynamically determined color to the next screen.
                          themeColor: cardColor,
                        );
                      },
                    ),
                  );
                },
                child: TintedContainer(
                  // The container's base color is now dynamic and not hardcoded.
                  baseColor: cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user.username,
                            style: TextStyle(
                              // Text color is now dynamic.
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            height: 30,
                            width: user.isLocked ? 150 : 100,
                            decoration: BoxDecoration(
                              // The badge color is now dynamic.
                              color: cardColor.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(
                                defaultRadius * 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "${user.isAdmin ? "Admin" : "User"} ${user.isLocked ? "(Locked)" : ""}",
                                style: const TextStyle(
                                  // White provides good contrast against the dynamic color.
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${user.firstName} ${user.lastName}",
                        style: TextStyle(
                          // Text color is now dynamic.
                          color: textColor,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        user.phoneNumber,
                        style: TextStyle(
                          // Text color is now dynamic.
                          color: textColor,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        user.address,
                        style: TextStyle(
                          // Text color is now dynamic.
                          color: textColor,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          // Text color is now dynamic.
                          color: textColor,
                          fontSize: 18,
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
