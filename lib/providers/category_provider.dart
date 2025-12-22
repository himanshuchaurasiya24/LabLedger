import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:labledger/models/diagnosis_category_model.dart';
import 'package:labledger/authentication/auth_repository.dart';
import 'package:labledger/authentication/config.dart';

// Provider for categories list
final categoriesProvider = FutureProvider.autoDispose<List<DiagnosisCategory>>((
  ref,
) async {
  final accessToken = await AuthRepository.instance.getAccessToken();
  if (accessToken == null) {
    throw Exception('Not authenticated');
  }

  final response = await http.get(
    Uri.parse('$globalBaseUrl/diagnosis/categories/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => DiagnosisCategory.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load categories');
  }
});

// Provider for creating/updating categories
class CategoryNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CategoryNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> createCategory({
    required String name,
    String? description,
    required bool isFranchiseLab,
  }) async {
    state = const AsyncValue.loading();

    try {
      final accessToken = await AuthRepository.instance.getAccessToken();
      final response = await http.post(
        Uri.parse('$globalBaseUrl/diagnosis/categories/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'description': description ?? '',
          'is_franchise_lab': isFranchiseLab,
          'is_active': true,
        }),
      );

      if (response.statusCode == 201) {
        state = const AsyncValue.data(null);
        // Refresh categories list
        ref.invalidate(categoriesProvider);
      } else {
        final error = json.decode(response.body);
        throw Exception(error.toString());
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    String? description,
    required bool isFranchiseLab,
  }) async {
    state = const AsyncValue.loading();

    try {
      final accessToken = await AuthRepository.instance.getAccessToken();
      final response = await http.patch(
        Uri.parse('$globalBaseUrl/diagnosis/categories/$id/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'description': description ?? '',
          'is_franchise_lab': isFranchiseLab,
        }),
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.data(null);
        ref.invalidate(categoriesProvider);
      } else {
        final error = json.decode(response.body);
        throw Exception(error.toString());
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    state = const AsyncValue.loading();

    try {
      final accessToken = await AuthRepository.instance.getAccessToken();
      final response = await http.delete(
        Uri.parse('$globalBaseUrl/diagnosis/categories/$id/'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 204) {
        state = const AsyncValue.data(null);
        ref.invalidate(categoriesProvider);
      } else {
        throw Exception('Failed to delete category');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<void>>((ref) {
      return CategoryNotifier(ref);
    });
