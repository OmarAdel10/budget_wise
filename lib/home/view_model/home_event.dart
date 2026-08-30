import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

class HomeEventLoadAllData extends HomeEvent {
  final DateTime monthDate;
  final String? accountId;
  const HomeEventLoadAllData(this.monthDate, {this.accountId});

  @override
  List<Object?> get props => [monthDate, accountId];
}

class HomeEventChangeMonth extends HomeEvent {
  final DateTime monthDate;
  const HomeEventChangeMonth(this.monthDate);

  @override
  List<Object?> get props => [monthDate];
}

class HomeEventChangeAccountFilter extends HomeEvent {
  final String? accountId;
  const HomeEventChangeAccountFilter(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class HomeEventFilterByCategory extends HomeEvent {
  final String? categoryId;
  const HomeEventFilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class HomeEventUpdateCategory extends HomeEvent {
  final CategoryModel category;
  const HomeEventUpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class HomeEventUpdateTransaction extends HomeEvent {
  final TransactionModel transaction;
  const HomeEventUpdateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
