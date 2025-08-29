import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/franchise_model.dart';
import 'package:labledger/providers/franchise_provider.dart';
import 'package:labledger/screens/database_overview/franchise_name/add_franchise_screen.dart';
import 'package:labledger/screens/profile/account_list_screen.dart';

class FranchiseNameListScreen extends ConsumerStatefulWidget {
  const FranchiseNameListScreen({super.key});

  @override
  ConsumerState<FranchiseNameListScreen> createState() =>
      _FranchiseNameListScreenState();
}

class _FranchiseNameListScreenState
    extends ConsumerState<FranchiseNameListScreen> {
  final TextEditingController searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    setWindowBehavior(removeTitleBar: true);
    searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Future<Map<String, List<Franchise>>> fetchFranchises() async {
    final franchisesAsync = ref.watch(franchiseProvider);
    final query = searchController.text.trim().toLowerCase();

    return franchisesAsync.when(
      data: (data) {
        if (query.isEmpty) {
          return {'All Franchises': data};
        }

        final nameMatches = <Franchise>[];
        final addressMatches = <Franchise>[];
        final phoneMatches = <Franchise>[];

        for (var franchise in data) {
          final name = franchise.franchiseName.toLowerCase();
          final address = franchise.address.toLowerCase();
          final phone = franchise.phoneNumber.toLowerCase();

          if (name.contains(query) || query.contains(name)) {
            nameMatches.add(franchise);
          } else if (address.contains(query) || query.contains(address)) {
            addressMatches.add(franchise);
          } else if (phone.contains(query) || query.contains(phone)) {
            phoneMatches.add(franchise);
          }
        }

        return {
          if (nameMatches.isNotEmpty) 'Name Matches': nameMatches,
          if (addressMatches.isNotEmpty) 'Address Matches': addressMatches,
          if (phoneMatches.isNotEmpty) 'Phone Matches': phoneMatches,
        };
      },
      error: (err, st) => {},
      loading: () => {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiaryFixed,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => AddFranchiseScreen()),
          );
        },
        label: Text(
          "Add Franchise",
          style: TextStyle(
            color: ThemeData.light().scaffoldBackgroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHeader(
              context: context,
              centerWidget: Row(
                children: [
                  CenterSearchBar(
                    controller: searchController,
                    hintText: "Search Franchises...",
                    searchFocusNode: searchFocusNode,
                    onSearch: (e) {
                      setState(() {}); // Trigger UI update
                    },
                  ),
                  const SizedBox(width: 160),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, List<Franchise>>>(
                future: fetchFranchises(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No franchises found.',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    );
                  }

                  final grouped = snapshot.data!;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: grouped.entries.map((e) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group title
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 6,
                              ),
                              child: Text(
                                e.key,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                            ),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 2.5,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: e.value.length,
                              itemBuilder: (ctx, index) {
                                final franchise = e.value[index];
                                return GridCard(
                                  context: context,
                                  onTap: () {
                                    navigatorKey.currentState?.push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddFranchiseScreen(
                                              franchise: franchise,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 55,
                                            width: 55,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            child: Center(
                                              child: Text(
                                                franchise.franchiseName[0]
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: ThemeData.light()
                                                      .scaffoldBackgroundColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  franchise.franchiseName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 24,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  franchise.address,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(fontSize: 16),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Phone: ${franchise.phoneNumber}",
                                        style: const TextStyle(fontSize: 20),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
