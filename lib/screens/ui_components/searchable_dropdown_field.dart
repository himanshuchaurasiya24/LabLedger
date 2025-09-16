// ignore_for_file: avoid_shadowing_type_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labledger/constants/constants.dart'; // For defaultPadding, etc.
import 'package:labledger/screens/ui_components/custom_text_field.dart'; // For CustomTextField

/// A reusable, searchable popup menu form field that looks like a CustomTextField.
class SearchableDropdownField<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final GlobalKey anchorKey = GlobalKey();

    return InkWell(
      key: anchorKey,
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (items.isEmpty) return;
        HapticFeedback.selectionClick();
        _showSearchableMenu<T>(
          context: context,
          anchorKey: anchorKey,
          color: color,
          items: items,
          valueMapper: valueMapper,
          onSelected: onSelected,
        );
      },
      child: AbsorbPointer(
        child: CustomTextField(
          label: label,
          controller: controller,
          readOnly: true,
          validator: validator,
          tintColor: color,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: color.withValues(alpha:  0.7),
            size: 24,
          ),
        ),
      ),
    );
  }

  Future<void> _showSearchableMenu<T>({
    required BuildContext context,
    required GlobalKey anchorKey,
    required Color color,
    required List<T> items,
    required String Function(T) valueMapper,
    required void Function(T) onSelected,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
        ? Color.alphaBlend(color.withValues(alpha:  0.25), theme.colorScheme.surface)
        : Color.alphaBlend(color.withValues(alpha:  0.1), theme.colorScheme.surface);
    final menuBorderColor = color.withValues(alpha:  isDark ? 0.5 : 0.4);

    await showMenu<T>(
      context: context,
      position: menuPosition,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha:  0.2),
      color: menuBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: menuBorderColor, width: 1),
      ),
      items: [
        PopupMenuItem<T>(
          enabled: false,
          child: _SearchableMenuContent<T>(
            items: items,
            valueMapper: valueMapper,
            onSelected: onSelected,
            color: color,
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
            .where((item) => widget
                .valueMapper(item)
                .toLowerCase()
                .contains(query.toLowerCase()))
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
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
                  title:
                      Text(widget.valueMapper(item), style: theme.textTheme.bodyMedium),
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