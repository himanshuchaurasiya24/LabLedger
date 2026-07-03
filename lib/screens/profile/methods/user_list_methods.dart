import 'package:flutter/material.dart';
import 'package:labledger/models/user_model.dart';

class UserListMethods extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';

  UserListMethods() {
    searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    notifyListeners();
  }

  List<User> filterUsers(List<User> users) {
    if (searchQuery.isEmpty) return users;

    return users.where((user) {
      final username = user.username.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final fullName = '${user.firstName} ${user.lastName}'
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ');
      final firstName = user.firstName.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final lastName = user.lastName.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final email = user.email.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final phoneNumber = user.phoneNumber.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final address = user.address.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );

      final query = searchQuery.trim().toLowerCase();
      return username.contains(query) ||
          fullName.contains(query) ||
          firstName.contains(query) ||
          lastName.contains(query) ||
          email.contains(query) ||
          phoneNumber.contains(query) ||
          address.contains(query);
    }).toList();
  }
}
