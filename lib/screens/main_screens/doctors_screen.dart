import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/methods/custom_methods.dart';

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
    // final doctorAsync = ref.watch(doctorNotifierProvider);
    return Scaffold(body: Column(children: [settingsPageTopBar(context)]));
  }
}
