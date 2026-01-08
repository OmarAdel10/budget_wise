import 'package:budget_wise/home/data/models/category_model.dart';
import 'package:equatable/equatable.dart';

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();
}

class CategoryEventCreateCategory extends CategoryEvent {
  final CategoryModel category;

  const CategoryEventCreateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryEventMarkSynced extends CategoryEvent {
  final String categoryId;

  const CategoryEventMarkSynced({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class CategoryEventSyncUnsynced extends CategoryEvent {
  const CategoryEventSyncUnsynced();

  @override
  List<Object?> get props => [];
}

// class CategoryEventLoadCategories extends CategoryEvent {
//   const CategoryEventLoadCategories();

//   @override
//   List<Object?> get props => [];
// }

class CategoryEventUpdateUserIdInAllCategoriesAfterFirstTimeLoginOnly extends CategoryEvent {
  const CategoryEventUpdateUserIdInAllCategoriesAfterFirstTimeLoginOnly();

  @override
  List<Object?> get props => [];
}

class CategoryEventFetchAll extends CategoryEvent {
  const CategoryEventFetchAll();

  @override
  List<Object?> get props => [];
}
