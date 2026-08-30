import 'dart:async';
import 'dart:developer';
import 'package:budget_wise/category/data/constants/category_constants.dart';
import 'package:budget_wise/category/data/constants/system_category_seed.dart';
import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/data/repositories/category_repository.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/transaction/data/repositories/transaction_repository.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

class CategoryBloc extends HydratedBloc<CategoryEvent, CategoryState> {
  final SettingsBloc settingsBloc;
  final AuthRepository authRepository;
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  late final StreamSubscription _authSubscription;

  CategoryBloc({
    required this.settingsBloc,
    required this.authRepository,
    required this.categoryRepository,
    required this.transactionRepository,
  }) : super(const CategoryStateInitial(categoriesList: [])) {
    _authSubscription = authRepository.authStateChanges.listen((user) {
      if (user != null && settingsBloc.state.model.hasLoggedIn) {
        add(const CategoryEventFetchAll());
      }
    });

    on<CategoryEventPreSeedDefaults>((event, emit) async {
      if (state.categoriesList.isNotEmpty) return;

      final List<CategoryModel> defaultCategories = [];
      final now = DateTime.now();
      final user = authRepository.currentUser;
      final userId = user?.uid ?? '';

      CategoryModel createCat(
        String title,
        IconData icon,
        TransactionType type,
      ) {
        return CategoryModel(
          id: const Uuid().v4(),
          userId: userId,
          categoryTitle: title,
          categoryIcon: icon,
          type: type,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        );
      }

      for (final entry in CategoryConstants.incomeCategories.entries) {
        defaultCategories.add(
          createCat(entry.key, entry.value.icon, TransactionType.income),
        );
      }
      for (final entry in CategoryConstants.expenseCategories.entries) {
        defaultCategories.add(
          createCat(entry.key, entry.value.icon, TransactionType.expense),
        );
      }
      for (final entry in CategoryConstants.transferCategories.entries) {
        defaultCategories.add(
          createCat(entry.key, entry.value.icon, TransactionType.transfer),
        );
      }

      defaultCategories.addAll(SystemCategorySeed.categories(userId, now));

      emit(
        CategoryStateSuccess(
          categoriesList: defaultCategories,
          totalSpentById: _buildZeroTotals(defaultCategories),
        ),
      );

      if (settingsBloc.state.model.hasLoggedIn && user != null) {
        for (final cat in defaultCategories) {
          categoryRepository.addCategory(cat).catchError((e) {
            log('Pre-seed sync failed for ${cat.categoryTitle}: $e');
          });
        }
      }
    });

    // Trigger pre-seed if list is empty (deferred to avoid blocking first frame)
    if (state.categoriesList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        add(const CategoryEventPreSeedDefaults());
      });
    }

    on<CategoryEventCreateCategory>((event, emit) {
      final user = authRepository.currentUser;
      try {
        final newCategory = event.category.copyWith(
          id: event.category.id.isEmpty ? const Uuid().v4() : event.category.id,
          userId: user != null ? user.uid : '',
          isSynced: false,
        );

        // Prevent duplicate categories with same title and type
        final alreadyExists = state.categoriesList.any(
          (c) =>
              c.categoryTitle == newCategory.categoryTitle &&
              c.type == newCategory.type,
        );
        if (alreadyExists) return;

        final updatedList = [...state.categoriesList, newCategory];
        final updatedTotals = Map<String, double>.from(state.totalSpentById)
          ..putIfAbsent(newCategory.id, () => 0.0);
        emit(
          CategoryStateSuccess(
            categoriesList: updatedList,
            totalSpentById: updatedTotals,
          ),
        );

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          categoryRepository
              .addCategory(newCategory)
              .then((_) {
                add(CategoryEventMarkSynced(categoryId: newCategory.id));
              })
              .catchError((e) {
                emit(
                  CategoryStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    categoriesList: state.categoriesList,
                    totalSpentById: state.totalSpentById,
                  ),
                );
              });
        }
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Local storage failed: ${e.toString()}',
            categoriesList: state.categoriesList,
            totalSpentById: state.totalSpentById,
          ),
        );
      }
    });

    on<CategoryEventUpdateCategory>((event, emit) {
      try {
        final updatedCategory = event.category.copyWith(isSynced: false);
        final updatedList = state.categoriesList.map((category) {
          return category.id == updatedCategory.id ? updatedCategory : category;
        }).toList();

        emit(
          CategoryStateSuccess(
            categoriesList: updatedList,
            totalSpentById: _retainTotals(updatedList, state.totalSpentById),
          ),
        );

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          categoryRepository
              .addCategory(updatedCategory)
              .then((_) {
                add(CategoryEventMarkSynced(categoryId: updatedCategory.id));
              })
              .catchError((e) {
                emit(
                  CategoryStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    categoriesList: state.categoriesList,
                    totalSpentById: state.totalSpentById,
                  ),
                );
              });
        }
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Local update failed: ${e.toString()}',
            categoriesList: state.categoriesList,
            totalSpentById: state.totalSpentById,
          ),
        );
      }
    });

    on<CategoryEventMarkSynced>((event, emit) {
      try {
        final updatedList = state.categoriesList.map((category) {
          if (category.id == event.categoryId) {
            return category.copyWith(isSynced: true);
          }
          return category;
        }).toList();
        emit(
          CategoryStateSuccess(
            categoriesList: updatedList,
            totalSpentById: _retainTotals(updatedList, state.totalSpentById),
          ),
        );
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Marking as synced failed: ${e.toString()}',
            categoriesList: state.categoriesList,
            totalSpentById: state.totalSpentById,
          ),
        );
      }
    });

    on<CategoryEventFetchAll>((event, emit) async {
      try {
        final remoteCategories = await categoryRepository.fetchAllCategories();
        final localCategoriesMap = {
          for (final cat in state.categoriesList) cat.id: cat,
        };
        final updatedList = <CategoryModel>[];

        for (final remoteItem in remoteCategories) {
          final localItem = localCategoriesMap[remoteItem.id];

          if (localItem == null) {
            updatedList.add(remoteItem);
          } else {
            if (remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
              updatedList.add(remoteItem);
            } else {
              updatedList.add(localItem);
            }
            localCategoriesMap.remove(remoteItem.id);
          }
        }

        updatedList.addAll(localCategoriesMap.values);
        emit(
          CategoryStateSuccess(
            categoriesList: updatedList,
            totalSpentById: await _buildTotalSpentById(updatedList),
          ),
        );
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Failed to fetch categories: ${e.toString()}',
            categoriesList: state.categoriesList,
            totalSpentById: state.totalSpentById,
          ),
        );
      }
    });

    on<CategoryEventDeleteCategory>((event, emit) async {
      try {
        final categoryToDelete = state.categoriesList.firstWhere(
          (category) => category.id == event.categoryId,
        );
        final updatedList = state.categoriesList
            .where((category) => category.id != event.categoryId)
            .toList();

        final updatedTotals = Map<String, double>.from(state.totalSpentById)
          ..remove(event.categoryId);
        emit(
          CategoryStateSuccess(
            categoriesList: updatedList,
            totalSpentById: updatedTotals,
          ),
        );

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          categoryRepository.deleteCategory(event.categoryId).catchError((e) {
            final restoredList = [categoryToDelete, ...state.categoriesList];
            emit(
              CategoryStateError(
                message: 'Cloud sync failed: ${e.toString()}',
                categoriesList: restoredList,
                totalSpentById: state.totalSpentById,
              ),
            );
          });
        }
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Delete failed: ${e.toString()}',
            categoriesList: state.categoriesList,
            totalSpentById: state.totalSpentById,
          ),
        );
      }
    });

    on<CategoryEventSyncPendingOnLogin>((event, emit) async {
      try {
        final pendingCategories = state.categoriesList
            .where(
              (category) =>
                  category.isSynced == false &&
                  authRepository.currentUser != null,
            )
            .toList();

        for (final category in pendingCategories) {
          final categoryWithUserId = category.copyWith(
            userId: authRepository.currentUser!.uid,
          );
          await categoryRepository
              .addCategory(categoryWithUserId)
              .then(
                (_) => add(
                  CategoryEventMarkSynced(categoryId: categoryWithUserId.id),
                ),
              )
              .catchError((e) {
                log('Failed to sync category ${category.id} on login: $e');
              });
        }
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Sync on login failed: ${e.toString()}',
            categoriesList: state.categoriesList,
            totalSpentById: state.totalSpentById,
          ),
        );
      }
    });

    on<CategoryEventCheckAndSyncPending>((event, emit) async {
      try {
        if (authRepository.currentUser == null) return;
        final pendingCategories = state.categoriesList
            .where((category) => category.isSynced == false)
            .toList();

        for (final category in pendingCategories) {
          await categoryRepository
              .addCategory(category)
              .then(
                (_) => add(CategoryEventMarkSynced(categoryId: category.id)),
              )
              .catchError((e) {
                log('Failed to sync category ${category.id}: $e');
              });
        }
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Check and sync failed: ${e.toString()}',
            categoriesList: state.categoriesList,
            totalSpentById: state.totalSpentById,
          ),
        );
      }
    });

    on<CategoryEventRefreshTotals>((event, emit) {
      emit(
        CategoryStateSuccess(
          categoriesList: state.categoriesList,
          totalSpentById: _buildTotalSpentByIdFromTransactions(
            state.categoriesList,
            event.transactions,
          ),
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  @override
  CategoryState? fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic>? list = json['categoryList'];
      if (list == null) {
        return const CategoryStateInitial(categoriesList: []);
      }
      final List<CategoryModel> categoryList = list
          .map((cat) => CategoryModel.fromMap(cat))
          .toList();
      final totalsRaw = json['totalSpentById'] as Map<String, dynamic>?;
      return CategoryStateSuccess(
        categoriesList: categoryList,
        totalSpentById: totalsRaw != null
            ? {
                for (final entry in totalsRaw.entries)
                  entry.key: (entry.value as num).toDouble(),
              }
            : {},
      );
    } catch (e) {
      log('Error during serialization: ${e.toString()}');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(CategoryState state) {
    return {
      'categoryList': state.categoriesList.map((cat) => cat.toMap()).toList(),
      'totalSpentById': state.totalSpentById,
    };
  }

  Map<String, double> _buildZeroTotals(List<CategoryModel> categories) {
    return {for (final category in categories) category.id: 0.0};
  }

  Map<String, double> _retainTotals(
    List<CategoryModel> categories,
    Map<String, double> currentTotals,
  ) {
    return {
      for (final category in categories)
        category.id: currentTotals[category.id] ?? 0.0,
    };
  }

  Future<Map<String, double>> _buildTotalSpentById(
    List<CategoryModel> categories,
  ) async {
    final transactions = await transactionRepository.fetchAllTransactions();
    return _buildTotalSpentByIdFromTransactions(categories, transactions);
  }

  Map<String, double> _buildTotalSpentByIdFromTransactions(
    List<CategoryModel> categories,
    List<TransactionModel> transactions,
  ) {
    return {
      for (final category in categories)
        category.id: _calculateTotalSpent(category.id, transactions),
    };
  }

  double _calculateTotalSpent(
    String categoryId,
    List<TransactionModel> transactions,
  ) {
    return transactions
        .where((transaction) => transaction.categoryId == categoryId)
        .fold(0.0, (sum, transaction) => sum + transaction.transactionAmount);
  }
}
