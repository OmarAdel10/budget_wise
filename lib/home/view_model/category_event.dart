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

class CategoryEventUpdateCategory extends CategoryEvent {
  final CategoryModel category;

  const CategoryEventUpdateCategory(this.category);

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

// class CategoryEventUpdateUserIdInAllCategoriesAfterFirstTimeLoginOnly extends CategoryEvent {
//   const CategoryEventUpdateUserIdInAllCategoriesAfterFirstTimeLoginOnly();

//   @override
//   List<Object?> get props => [];
// }

class CategoryEventFetchAll extends CategoryEvent {
  const CategoryEventFetchAll();

  @override
  List<Object?> get props => [];
}

class CategoryEventDeleteCategory extends CategoryEvent {
  final String categoryId;

  const CategoryEventDeleteCategory({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class CategoryEventReorder extends CategoryEvent {
  final int oldIndex;
  final int newIndex;

  const CategoryEventReorder({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class CategoryEventSyncPendingOnLogin extends CategoryEvent {
  const CategoryEventSyncPendingOnLogin();

  @override
  List<Object?> get props => [];
}

class CategoryEventCheckAndSyncPending extends CategoryEvent {
  const CategoryEventCheckAndSyncPending();

  @override
  List<Object?> get props => [];
}
