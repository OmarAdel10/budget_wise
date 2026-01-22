import 'dart:developer';
import 'package:budget_wise/home/data/models/category_model.dart';
import 'package:budget_wise/home/data/repositories/category_repository.dart';
import 'package:budget_wise/home/view_model/category_event.dart';
import 'package:budget_wise/home/view_model/category_state.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

class CategoryBloc extends HydratedBloc<CategoryEvent, CategoryState> {
  final SettingsBloc settingsBloc;
  final AuthRepository authRepository;
  final CategoryRepository categoryRepository;
  CategoryBloc({
    required this.settingsBloc,
    required this.authRepository,
    required this.categoryRepository,
  }) : super(const CategoryStateInitial(categoriesList: [])) {
    authRepository.authStateChanges.listen((user) {
      if (user != null &&
          settingsBloc.state.model.hasLoggedIn &&
          state.categoriesList.isEmpty) {
        add(const CategoryEventFetchAll());
      }
    });
    on<CategoryEventCreateCategory>((event, emit) {
      try {
        final userId = authRepository.currentUser?.uid ?? '';
        final newCategory = event.category
          ..id = const Uuid().v4()
          ..userId = userId
          ..isSynced = false
          ..index = state.categoriesList.length;

        // Prevent duplicate categories with same title and type
        final alreadyExists = state.categoriesList.any(
          (c) =>
              c.categoryTitle == newCategory.categoryTitle &&
              c.type == newCategory.type,
        );
        if (alreadyExists) return;

        final updatedList = [...state.categoriesList, newCategory];
        emit(CategoryStateSuccess(categoriesList: updatedList));

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
                  ),
                );
              });
        }
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Local storage failed: ${e.toString()}',
            categoriesList: state.categoriesList,
          ),
        );
      }
    });

    on<CategoryEventReorder>((event, emit) {
      try {
        final List<CategoryModel> updatedList = List.from(state.categoriesList);
        int newIndex = event.newIndex;
        if (event.oldIndex < event.newIndex) {
          newIndex -= 1;
        }
        final item = updatedList.removeAt(event.oldIndex);
        updatedList.insert(newIndex, item);

        // Update indexes
        final reindexedList = updatedList.asMap().entries.map((entry) {
          return entry.value.copyWith(index: entry.key);
        }).toList();

        emit(CategoryStateSuccess(categoriesList: reindexedList));

        if (settingsBloc.state.model.hasLoggedIn) {
          categoryRepository.updateCategoryIndexes(reindexedList).catchError((
            e,
          ) {
            emit(
              CategoryStateError(
                message: 'Index update failed: ${e.toString()}',
                categoriesList: state.categoriesList,
              ),
            );
          });
        }
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Reorder failed: ${e.toString()}',
            categoriesList: state.categoriesList,
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

        emit(CategoryStateSuccess(categoriesList: updatedList));

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
                  ),
                );
              });
        }
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Local update failed: ${e.toString()}',
            categoriesList: state.categoriesList,
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
        emit(CategoryStateSuccess(categoriesList: updatedList));
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Marking as synced failed: ${e.toString()}',
            categoriesList: state.categoriesList,
          ),
        );
      }
    });

    on<CategoryEventFetchAll>((event, emit) async {
      try {
        final categories = await categoryRepository.fetchAllCategories();
        emit(CategoryStateSuccess(categoriesList: categories));
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Failed to fetch categories: ${e.toString()}',
            categoriesList: state.categoriesList,
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

        emit(CategoryStateSuccess(categoriesList: updatedList));

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          categoryRepository.deleteCategory(event.categoryId).catchError((e) {
            final restoredList = [categoryToDelete, ...state.categoriesList];
            emit(
              CategoryStateError(
                message: 'Cloud sync failed: ${e.toString()}',
                categoriesList: restoredList,
              ),
            );
          });
        }
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Delete failed: ${e.toString()}',
            categoriesList: state.categoriesList,
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
          ),
        );
      }
    });
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
      return CategoryStateSuccess(categoriesList: categoryList);
    } catch (e) {
      log('Error during serialization: ${e.toString()}');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(CategoryState state) {
    return {
      'categoryList': state.categoriesList.map((cat) => cat.toMap()).toList(),
    };
  }
}
