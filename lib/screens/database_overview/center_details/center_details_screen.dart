import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/database_overview/center_details/update_center_details_screen.dart';
import 'package:labledger/screens/profile/profile_screen.dart';

class CenterDetailsScreen extends ConsumerWidget {
  const CenterDetailsScreen({super.key, required this.userId});
  final int userId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailsProvider(userId));

    return Scaffold(
      body: CustomCardContainer(
        xHeight: 0.95,
        xWidth: 0.5,
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (user) {
            if (user == null) {
              return const Center(child: Text("User not found"));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pageHeader(context: context, centerWidget: null),
                ProfileField(
                  label: "Center Name",
                  value: user.centerDetail.centerName,
                ),
                ProfileField(
                  label: "Center Address",
                  value: user.centerDetail.address,
                ),

                ProfileField(
                  label: "Center Owner",
                  value: user.centerDetail.ownerName,
                ),

                ProfileField(
                  label: "Owner Phone",
                  value: user.centerDetail.ownerPhone,
                ),

                Spacer(), // pushes the button to the bottom

                InkWell(
                  onTap: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (context) {
                          return UpdateCenterDetailsScreen(
                            centerDetail: user.centerDetail,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                    child: Center(
                      child: Text(
                        "Update Details",
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
