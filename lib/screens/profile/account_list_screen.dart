import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/main.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home/add_bill_screen.dart';
import 'package:labledger/screens/profile/profile_screen.dart';

class AccountListScreen extends ConsumerWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersDetailsProvider(null));
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.95,
          width: MediaQuery.of(context).size.width * 0.5,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryFixed,
            borderRadius: BorderRadius.circular(defaultPadding / 2),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: defaultPadding / 2,
              right: defaultPadding / 2,
              bottom: defaultPadding / 2,
            ),
            child: Column(
              children: [
                buildHeader(context),
                usersAsync.when(
                  data: (users) => Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return GestureDetector(
                          onTap: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProfileScreen(userId: user.id),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    defaultPadding / 2,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${user.firstName} ${user.lastName}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall!
                                                .copyWith(
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? ThemeData.light()
                                                            .colorScheme
                                                            .surface
                                                      : ThemeData.dark()
                                                            .colorScheme
                                                            .surface,
                                                ),
                                          ),
                                          Container(
                                            height: 40,
                                            width: 150,

                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: user.isAdmin
                                                    ? Color(0xFF0072B5)
                                                    : Colors.green,
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                user.isAdmin
                                                    ? "ADMINISTRATOR"
                                                    : "USER",
                                                style: TextStyle(
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? ThemeData.light()
                                                            .colorScheme
                                                            .surface
                                                      : ThemeData.dark()
                                                            .colorScheme
                                                            .surface,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Email: ${user.email}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        "Username: ${user.username}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        "Address: ${user.address}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        "Phone Number: ${user.phoneNumber}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text('Error: $err'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
