import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
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

class CategoryEventPreSeedDefaults extends CategoryEvent {
  const CategoryEventPreSeedDefaults();

  @override
  List<Object?> get props => [];
}

class CategoryEventRefreshTotals extends CategoryEvent {
  final List<TransactionModel> transactions;

  const CategoryEventRefreshTotals({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}
