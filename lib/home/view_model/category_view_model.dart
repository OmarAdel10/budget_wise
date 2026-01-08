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
      if (user != null && settingsBloc.state.model.isSyncToCloudEnabled) {
        add(const CategoryEventFetchAll());
      }
    });
    on<CategoryEventCreateCategory>((event, emit) {
      try {
        final userId = authRepository.currentUser?.uid ?? '';
        final newCategory = event.category;
        if (newCategory.id.isEmpty) {
          newCategory.id = const Uuid().v4();
        }
        newCategory.userId = userId;

        final updatedList = [newCategory, ...state.categoriesList];
        emit(CategoryStateSuccess(categoriesList: updatedList));

        if (settingsBloc.state.model.isSyncToCloudEnabled == true) {
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

    on<CategoryEventSyncUnsynced>((event, emit) async {
      try {
        final unSynced = state.categoriesList
            .where((category) => category.isSynced == false)
            .toList();
        if (unSynced.isEmpty) return;
        final synced = unSynced.map((category) {
          return categoryRepository.addCategory(category).then((_) {
            add(CategoryEventMarkSynced(categoryId: category.id));
          });
        }).toList();
        await Future.wait(synced);
      } catch (e) {
        emit(
          CategoryStateError(
            message: 'Marking as unsynced failed: ${e.toString()}',
            categoriesList: state.categoriesList,
          ),
        );
      }
    });

    on<CategoryEventUpdateUserIdInAllCategoriesAfterFirstTimeLoginOnly>((
      event,
      emit,
    ) {
      try {
        final userId = authRepository.currentUser?.uid;
        if (userId != null) {
          final updatedList = state.categoriesList.map((category) {
            if (category.userId.isEmpty) {
              return category.copyWith(userId: userId);
            }
            return category;
          }).toList();

          if (settingsBloc.state.model.isSyncToCloudEnabled) {
            categoryRepository
                .updateUserIdInAllCategoriesAfterFirstTimeLoginOnly();
          }

          emit(CategoryStateSuccess(categoriesList: updatedList));
        }
      } catch (e) {
        emit(
          CategoryStateError(
            message: e.toString(),
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
