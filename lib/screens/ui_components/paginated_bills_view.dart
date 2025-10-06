import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/bill_model.dart';
import 'package:labledger/models/paginated_response.dart';
import 'package:labledger/methods/pagination_controls.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/screens/ui_components/cards/bill_card.dart';
import 'package:labledger/constants/constants.dart';

class PaginatedBillsView extends ConsumerWidget {
  final AsyncValue<PaginatedBillsResponse> billsProvider;
  final String selectedView;
  final String headerTitle;
  final String emptyListMessage;
  final void Function(int) onPageChanged;
  final void Function(Bill) onBillTap;
  final VoidCallback onRetry;

  const PaginatedBillsView({
    super.key,
    required this.billsProvider,
    required this.selectedView,
    required this.headerTitle,
    required this.emptyListMessage,
    required this.onPageChanged,
    required this.onBillTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
     Color positiveColor = Theme.of(context).colorScheme.secondary;
     Color negativeColor = Theme.of(context).colorScheme.error;
    const Color neutralColor = Colors.amber;

    return billsProvider.when(
      data: (response) {
        final bills = response.bills;

        if (bills.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Text(
                emptyListMessage,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedView == "grid")
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: size.width > 1600 ? 2.4 : 2.0,
                  crossAxisSpacing: defaultWidth,
                  mainAxisSpacing: defaultHeight,
                ),
                itemCount: bills.length,
                itemBuilder: (ctx, index) {
                  final bill = bills[index];
                  return BillCard(
                    bill: bill,
                    onTap: () => onBillTap(bill),
                    fullyPaidColor: positiveColor,
                    partiallyPaidColor: neutralColor,
                    unpaidColor: negativeColor,
                  );
                },
              ),
            if (selectedView == "list")
              ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: bills.length,
                separatorBuilder: (_, _) => SizedBox(height: defaultHeight),
                itemBuilder: (ctx, index) {
                  final bill = bills[index];
                  return BillCard(
                    bill: bill,
                    onTap: () => onBillTap(bill),
                    fullyPaidColor: positiveColor,
                    partiallyPaidColor: neutralColor,
                    unpaidColor: negativeColor,
                  );
                },
              ),
            const SizedBox(height: 20),
            PaginationControls(
              totalItems: response.count,
              itemsPerPage: 40,
              currentPage: ref.watch(currentPageProvider),
              onPageChanged: onPageChanged,
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Failed to load bills",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(err.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}