import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:labledger/providers/custom_providers.dart';
import 'package:labledger/providers/doctor_provider.dart';
import 'package:labledger/screens/main_screens/doctor_screen/hover_container.dart';

class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key});

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen> {
  @override
  void initState() {
    super.initState();
    setWindowBehavior(removeTitleBar: true);
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(doctorNotifierProvider);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: defaultPadding * 2,
              right: defaultPadding * 2,
              top: defaultPadding,
            ),
            child: settingsPageTopBar(
              context: context,
              pageName: "Doctors List",
              chipColor: Colors.red[600]!,
            ),
          ),
          const SizedBox(height: 10),
          doctorAsync.when(
            data: (doctors) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate width based on desired 3 columns
                      final crossAxisCount = 3;
                      final spacing = 5.0; // spacing between items
                      final totalSpacing = spacing * (crossAxisCount - 1);
                      final itemWidth =
                          (constraints.maxWidth - totalSpacing) /
                          crossAxisCount;
                      final aspectRatio = 510 / 250;
                      final itemHeight = itemWidth / aspectRatio;

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 4.0, // 👈 Small vertical gap
                          childAspectRatio: aspectRatio,
                        ),

                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          return HoverScaleContainer(
                            width: itemWidth,
                            height: itemHeight,
                            doctor: doctors[index],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }
}
