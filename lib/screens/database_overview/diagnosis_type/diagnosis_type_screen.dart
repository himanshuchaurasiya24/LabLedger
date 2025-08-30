import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/constants/constants.dart';
import 'package:labledger/main.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/models/diagnosis_type_model.dart';
import 'package:labledger/providers/diagnosis_type_provider.dart';
import 'package:labledger/screens/database_overview/diagnosis_type/add_diagnosis_type_screen.dart';
import 'package:labledger/screens/profile/account_list_screen.dart';

class DiagnosisTypeScreen extends ConsumerStatefulWidget {
  const DiagnosisTypeScreen({super.key});

  @override
  ConsumerState<DiagnosisTypeScreen> createState() =>
      _DiagnosisTypeScreenState();
}

class _DiagnosisTypeScreenState extends ConsumerState<DiagnosisTypeScreen> {
  final TextEditingController searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Future<Map<String, List<DiagnosisType>>> fetchDiagnosisTypes() async {
    final diagnosisTypesAsync = ref.watch(diagnosisTypeProvider);
    final query = searchController.text.trim().toLowerCase();

    return diagnosisTypesAsync.when(
      data: (data) {
        if (query.isEmpty) {
          return {'All Diagnosis Types': data};
        }

        final nameMatches = <DiagnosisType>[];
        final categoryMatches = <DiagnosisType>[];
        final priceMatches = <DiagnosisType>[];
        for (var diagnosis in data) {
          final name = diagnosis.name.toLowerCase();
          final category = diagnosis.category.toLowerCase();
          final price = diagnosis.price.toString();
          if (name.contains(query) || query.contains(name)) {
            nameMatches.add(diagnosis);
          } else if (category.contains(query) || query.contains(category)) {
            categoryMatches.add(diagnosis);
          } else if (price.contains(query) || query.contains(price)) {
            priceMatches.add(diagnosis);
          }
        }

        return {
          if (nameMatches.isNotEmpty) 'Name Matches': nameMatches,
          if (categoryMatches.isNotEmpty) 'Category Matches': categoryMatches,
          if (priceMatches.isNotEmpty) 'Amount Matches': priceMatches,
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
            MaterialPageRoute(builder: (context) => AddDiagnosisTypeScreen()),
          );
        },
        label: Text(
          "Add Diagnosis Type",
          style: TextStyle(
            color: ThemeData.light().scaffoldBackgroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHeader(
              context: context,
              centerWidget: Row(
                children: [
                  CenterSearchBar(
                    controller: searchController,
                    hintText: "Search Diagnosis Types...",
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
              child: FutureBuilder<Map<String, List<DiagnosisType>>>(
                future: fetchDiagnosisTypes(),
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
                        'No diagnosis types found.',
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
                                final diagnosis = e.value[index];
                                return GridCard(
                                  context: context,
                                  onTap: () {
                                    navigatorKey.currentState?.push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddDiagnosisTypeScreen(
                                              diagnosisType: diagnosis,
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
                                                diagnosis.name[0].toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: ThemeData.light()
                                                      .scaffoldBackgroundColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: defaultWidth),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  diagnosis.name,
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
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    diagnosis.category,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "₹${diagnosis.price}",
                                        style: TextStyle(
                                          fontSize: 30,
                                          // fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
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
