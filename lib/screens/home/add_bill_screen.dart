import 'package:flutter/material.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.76,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.tertiaryFixed.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}
