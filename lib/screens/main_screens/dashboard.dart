import 'package:flutter/material.dart';
import 'package:labledger/methods/custom_methods.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SummaryCard(
              title: 'Total Patients',
              count: '1200',
              icon: LucideIcons.user,
            ),
            SummaryCard(
              title: 'Reports Generated',
              count: '450',
              icon: LucideIcons.bookOpen,
            ),
            SummaryCard(
              title: 'Active Doctors',
              count: '32',
              icon: LucideIcons.userCheck,
            ),
            SummaryCard(
              title: "Today's Appointments",
              count: '18',
              icon: LucideIcons.calendar,
            ),
          ],
        ),
        SizedBox(height: 32),

        // Recent Reports
        const Text(
          'Recent Reports',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Patient Name')),
              DataColumn(label: Text('Report Type')),
              DataColumn(label: Text('Status')),
            ],
            rows: const [
              DataRow(
                cells: [
                  DataCell(Text('John Doe')),
                  DataCell(Text('Blood Test')),
                  DataCell(Text('Completed')),
                ],
              ),
              DataRow(
                cells: [
                  DataCell(Text('Jane Smith')),
                  DataCell(Text('X-Ray')),
                  DataCell(Text('Pending')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
