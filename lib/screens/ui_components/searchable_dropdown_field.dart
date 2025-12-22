// ignore_for_file: avoid_shadowing_type_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/constants/constants.dart'; // For defaultPadding, etc.
import 'package:labledger/screens/ui_components/custom_text_field.dart'; // For CustomTextField

/// A reusable, searchable popup menu form field that looks like a CustomTextField.
class SearchableDropdownField<T> extends StatefulWidget {
  const SearchableDropdownField({
    super.key,
    required this.label,
    required this.controller,
    required this.items,
    required this.valueMapper,
    required this.onSelected,
    required this.color,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final List<T> items;
  final String Function(T) valueMapper;
  final void Function(T) onSelected;
  final Color color;
  final String? Function(String?)? validator;

  @override
  State<SearchableDropdownField<T>> createState() =>
      _SearchableDropdownFieldState<T>();
}

class _SearchableDropdownFieldState<T>
    extends State<SearchableDropdownField<T>> {
  final GlobalKey anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: anchorKey,
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        print(
          'DEBUG: SearchableDropdownField tapped. Label: ${widget.label}, Items: ${widget.items.length}',
        );
        if (widget.items.isEmpty) {
          print('DEBUG: Items empty, returning.');
          return;
        }
        HapticFeedback.selectionClick();
        try {
          _showSearchableMenu(context);
        } catch (e, stack) {
          print('DEBUG: Error showing menu: $e\n$stack');
        }
      },
      child: AbsorbPointer(
        child: CustomTextField(
          label: widget.label,
          controller: widget.controller,
          readOnly: true,
          validator: widget.validator,
          tintColor: widget.color,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: widget.color.withValues(alpha: 0.7),
            size: 24,
          ),
        ),
      ),
    );
  }

  Future<void> _showSearchableMenu(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Ensure the key is mounted
    if (anchorKey.currentContext == null) {
      print('DEBUG: anchorKey context is null');
      return;
    }

    final RenderBox renderBox =
        anchorKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final menuPosition = RelativeRect.fromLTRB(
      position.dx,
      position.dy + size.height + 4,
      position.dx + size.width,
      position.dy,
    );
    final menuBackgroundColor = isDark
        ? Color.alphaBlend(
            widget.color.withValues(alpha: 0.25),
            theme.colorScheme.surface,
          )
        : Color.alphaBlend(
            widget.color.withValues(alpha: 0.1),
            theme.colorScheme.surface,
          );
    final menuBorderColor = widget.color.withValues(alpha: isDark ? 0.5 : 0.4);

    await showMenu<T>(
      context: context,
      position: menuPosition,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      color: menuBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: menuBorderColor, width: 1),
      ),
      items: [
        PopupMenuItem<T>(
          enabled: false,
          child: _SearchableMenuContent<T>(
            items: widget.items,
            valueMapper: widget.valueMapper,
            onSelected: widget.onSelected,
            color: widget.color,
            parentSize: size,
            menuBorderColor: menuBorderColor,
          ),
        ),
      ],
    );
  }
}

/// The stateful content of the searchable popup menu.
class _SearchableMenuContent<T> extends StatefulWidget {
  const _SearchableMenuContent({
    required this.items,
    required this.valueMapper,
    required this.onSelected,
    required this.color,
    required this.parentSize,
    required this.menuBorderColor,
  });

  final List<T> items;
  final String Function(T) valueMapper;
  final void Function(T) onSelected;
  final Color color;
  final Size parentSize;
  final Color menuBorderColor;

  @override
  State<_SearchableMenuContent<T>> createState() =>
      _SearchableMenuContentState<T>();
}

class _SearchableMenuContentState<T> extends State<_SearchableMenuContent<T>> {
  late List<T> _filteredItems;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
              (item) => widget
                  .valueMapper(item)
                  .toLowerCase()
                  .contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: widget.parentSize.width,
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search, size: 18, color: widget.color),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  borderSide: BorderSide(color: widget.menuBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  borderSide: BorderSide(color: widget.color, width: 1.5),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return ListTile(
                  title: Text(
                    widget.valueMapper(item),
                    style: theme.textTheme.bodyMedium,
                  ),
                  onTap: () {
                    widget.onSelected(item);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
