import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:labledger/screens/ui_components/custom_text_field.dart'; 

class PaginationControls extends StatefulWidget {
  const PaginationControls({
    super.key,
    required this.totalItems,
    required this.itemsPerPage,
    required this.currentPage,
    required this.onPageChanged,
  });

  final int totalItems;
  final int itemsPerPage;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  State<PaginationControls> createState() => _PaginationControlsState();
}

class _PaginationControlsState extends State<PaginationControls> {
  late final TextEditingController _pageController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(text: widget.currentPage.toString());
    _focusNode = FocusNode();
        _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _submitPage();
      }
    });
  }

  @override
  void didUpdateWidget(covariant PaginationControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // This is crucial. If the parent updates the page (e.g., via arrow buttons),
    // we must update our text controller to match the new state,
    // but only if the user isn't currently typing in it.
    if (widget.currentPage != oldWidget.currentPage && !_focusNode.hasFocus) {
      _updateTextToCurrentPage();
    }
  }

  void _updateTextToCurrentPage() {
    _pageController.text = widget.currentPage.toString();
    // Move cursor to the end
    _pageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _pageController.text.length));
  }

  void _submitPage() {
    final totalPages = (widget.totalItems / widget.itemsPerPage).ceil();

    // Try to parse the user's input
    int newPage = int.tryParse(_pageController.text) ?? widget.currentPage;

    // Validate and clamp the input
    if (newPage < 1) {
      newPage = 1;
    } else if (newPage > totalPages) {
      newPage = totalPages;
    }

    // Only call the callback if the page is actually different
    if (newPage != widget.currentPage) {
      widget.onPageChanged(newPage);
    }
    
    // After submitting, always reset the text to the (potentially validated) new page
    // This handles cases where the user types an invalid page like "999"
    _pageController.text = newPage.toString();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.removeListener(_submitPage); // Clean up listener
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalItems <= widget.itemsPerPage) {
      return const SizedBox.shrink(); // Hide controls if only one page
    }

    final totalPages = (widget.totalItems / widget.itemsPerPage).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: widget.currentPage == 1
                ? null // Disable on first page
                : () {
                    widget.onPageChanged(widget.currentPage - 1);
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
            onPressed: widget.currentPage == totalPages
                ? null // Disable on last page
                : () {
                    widget.onPageChanged(widget.currentPage + 1);
                  },
          ),
        ],
      ),
    );
  }
}