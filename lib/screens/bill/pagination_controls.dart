
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/providers/bills_provider.dart';
import 'package:labledger/screens/ui_components/custom_text_field.dart';

/// --- UPDATED PAGINATION WIDGET ---
/// This is now a ConsumerStatefulWidget to manage the controller and focus node
/// for the "Go to Page" text field.
class PaginationControls extends ConsumerStatefulWidget {
  const PaginationControls({super.key, 
    required this.totalItems,
    required this.itemsPerPage,
  });

  final int totalItems;
  final int itemsPerPage;

  @override
  ConsumerState<PaginationControls> createState() => _PaginationControlsState();
}

class _PaginationControlsState extends ConsumerState<PaginationControls> {
  late final TextEditingController _pageController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController();
    _focusNode = FocusNode();
    // Add a listener to submit when the user taps away (loses focus)
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _submitPage();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitPage() {
    final totalPages = (widget.totalItems / widget.itemsPerPage).ceil();
    final currentPage = ref.read(currentPageProvider);
    
    // Try to parse the user's input
    int newPage = int.tryParse(_pageController.text) ?? currentPage;

    // Validate and clamp the input (constrain to max page count)
    if (newPage < 1) {
      newPage = 1;
    } else if (newPage > totalPages) {
      newPage = totalPages;
    }

    // Only update the state if the page number is actually different
    if (newPage != currentPage) {
      ref.read(currentPageProvider.notifier).state = newPage;
    }

    // Unfocus to hide keyboard
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalItems <= widget.itemsPerPage) {
      return const SizedBox.shrink(); // Hide controls if only one page
    }
    
    final currentPage = ref.watch(currentPageProvider);
    final totalPages = (widget.totalItems / widget.itemsPerPage).ceil();

    // Sync the text controller with the current page from the provider.
    // This ensures it updates when the user clicks the arrow buttons.
    // We also check focus to avoid interrupting the user while they are typing.
    if (!_focusNode.hasFocus && _pageController.text != currentPage.toString()) {
       _pageController.text = currentPage.toString();
       // Move cursor to the end
       _pageController.selection = TextSelection.fromPosition(TextPosition(offset: _pageController.text.length));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage == 1
                ? null // Disable on first page
                : () {
                    ref.read(currentPageProvider.notifier).state = currentPage - 1;
                  },
          ),
          const SizedBox(width: 8),
          Text(
            'Page',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60, // Constrain the width of the text field
            height: 40, // Give it a specific height
            child: CustomTextField(
              controller: _pageController,
              focusNode: _focusNode,
              label: '', // Label is handled externally by our "Page" text
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _submitPage(),
              textAlign: TextAlign.center,
              tintColor: const Color(0xFF0072B5), // Use your primary color tint
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'of $totalPages',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage == totalPages
                ? null // Disable on last page
                : () {
                    ref.read(currentPageProvider.notifier).state = currentPage + 1;
                  },
          ),
        ],
      ),
    );
  }
}