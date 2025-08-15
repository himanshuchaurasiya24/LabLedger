import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/screens/home/add_bill_screen.dart';

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
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          title: Text('${user.firstName} ${user.lastName}'),
                          subtitle: Text(
                            "${user.email} isAdmin: ${user.isAdmin}",
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
